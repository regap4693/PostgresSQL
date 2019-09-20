\qecho 'Question 1a'
create or replace function mapper (A int, B int) returns table (A int, cpA int) as
$$
select A,A as cpA;
$$ Language SQL;

create or replace function reducer (A int, grp_A int[]) returns table (A int, op_A int) as
$$
select reducer.A,reducer.A as op_A;
$$language SQL;

with 
map_output as (select q.A,q.cpA from R r, Lateral(select p.A,p.cpA from mapper(r.A,r.B) p) q),

group_output as (select p.A,array_agg(p.cpA) as grp_A from map_output p group by p.A),

reduce_output as (select t.A,t.op_A from group_output r, lateral(select A,op_A from reducer(r.A,r.grp_A) s) t)
select A from reduce_output;

\qecho 'Question 1b'
create or replace function mapperB (A int,rel text) returns table (A int, rel text) as
$$
select A,rel;
$$ Language SQL;

create or replace function reducerB (A int, rels text[]) returns table (A1 int,A2 int) as
$$
select A as A1,A as A2 where rels =array['R'];
$$Language SQL;


with 
map_outputB as (select q.A,q.rel from R r, lateral(select p.A,p.rel from mapperB(r.A,'R') p)q union select q.A,q.rel from S s, lateral(select p.A,p.rel from mapperB(s.A,'S') p)q),

group_outputB as (select p.A,array_agg(p.rel) as rels from map_outputB p group by p.A),

reduce_outputB as (select t.A1 as A,t.A2 from group_outputB gb, lateral(select A1,A2 from reducerB(gb.A,gb.rels) s) t)
select A from reduce_outputB;

\qecho 'Question 1c'
create type typeVal as (rel1 text,att int);
create or replace function mapperC (at1 int,at2 int,rel text) returns table (k int,val typeVal) as
$$
select  at2,(rel,at1)::typeVal where rel='R'
union
select  at1,(rel,at2)::typeVal where rel='S';
$$ Language sql;

create type typeRVal as (a int,b int,c int);
create or replace function reducerC (k int,vals typeVal[]) returns table (opK int,opVal typeRVal) as
$$
select k,(qq1.a,k,qq2.c)::typeRVal from (select (q1.uv).att as a from (select unnest(vals) as uv) q1 where (q1.uv).rel1='R') qq1 cross join 
(select (q1.uv).att as c from (select unnest(vals) as uv) q1 where (q1.uv).rel1='S') qq2 ;
$$ Language sql;

with
map_outputC as (select q.k,q.val from R r, lateral(select p.k,p.val from mapperC(r.A,r.B,'R') p) q union select q.k,q.val from S s, lateral(select p.k,p.val from mapperC(s.B,s.C,'S') p) q),

group_outputC as (select p.k,array_agg(p.val) as vals from map_outputC p group by p.k),

reduce_outputC as (select t.opK,t.opVal from group_outputC gc, lateral(select opK,opVal from reducerC(gc.k,gc.vals) s) t)

select (opVal).a,(opVal).b,(opVal).c from reduce_outputC;

\qecho 'Question 1d'
--we use the same mapper in 1b- mapperB
create or replace function reducerD (A int,rels text[]) returns table (A1 int, A2 int) as
$$
select A as A1,A as A2 where 'R'=SOME(rels) and not('S'=SOME(rels))
union 
select A as A1,A as A2 where 'T'=SOME(rels) and not('R'=SOME(rels))
$$Language sql;

with 
map_outputD as (
select q.A,q.rel from R r, lateral(select p.A,p.rel from mapperB(r.A,'R') p)q union 
select q.A,q.rel from S s, lateral(select p.A,p.rel from mapperB(s.A,'S') p)q union
select q.A,q.rel from T t, lateral(select p.A,p.rel from mapperB(t.A,'T') p)q),

group_outputD as (select p.A,array_agg(p.rel) as rels from map_outputD p group by p.A),

reduce_outputD as (select t.A1 as A,t.A2 from group_outputD gd, lateral(select A1,A2 from reducerD(gd.A,gd.rels) s) t)
select A from reduce_outputD;

--evaluate
create table R (A int);
insert into R values (1),(5),(6),(7),(3),(2),(1),(9),(6);
create table S (A int);
insert into S values (12),(33),(4),(5),(6),(7),(8),(1);
create table T (A int);
insert into T values (12),(39),(9),(7),(10),(1),(2),(8);
--below gives the same result as mapreduce
(select * from R except select * from S) union (select * from T except select * from R);

\qecho 'Question 2a'
create type cogrpType1 as (
RV_values int[],
SW_values int[]
);

create view cogroupRS as (
SELECT K, (RV_values, SW_values)::cogrpType1 as Val
FROM (SELECT r.K, ARRAY_AGG(r.V) AS RV_values
FROM R r
GROUP BY (r.K)
UNION
SELECT k.K, '{}' AS RV_VALUES FROM (SELECT r.K FROM R r UNION SELECT s.K FROM S s) k
WHERE k.K NOT IN (SELECT r.K FROM R r)) R_K 
NATURAL JOIN 
(SELECT s.K, ARRAY_AGG(s.W) AS SW_values
FROM S s
GROUP BY (s.K)
UNION
SELECT k.K, '{}' AS SW_VALUES FROM (SELECT r.K FROM R r UNION SELECT s.K FROM S s) k
WHERE k.K NOT IN (SELECT s.K FROM S s)) S_K);

--show that the view works:
create table R (K int, V int);
create table S (K int, W int);
insert into R values (1,2),(2,3),(1,4),(1,5),(6,7),(7,8);
insert into S values (1,9),(2,12),(10,4),(3,6),(2,3);
select * from cogroupRS;
/*
 k  |       val
----+-----------------
  1 | ("{2,4,5}",{9})
  2 | ({3},"{12,3}")
  3 | ({},{6})
  6 | ({7},{})
  7 | ({8},{})
 10 | ({},{4})
(6 rows)
*/

\qecho 'Question 2b'
create type nattype as (k int,V int,W int);
create or replace function naturaljoin(k int,RV_values int[],SW_values int[]) returns table (val nattype) as
$$
select q.k,unnest(q.RV_values) as V,q.W 
from (
select k,RV_values,unnest(SW_values) as W  
where not( RV_values <@ '{}' or SW_values <@ '{}')) q;
$$Language SQL;

select (q.val).k,(q.val).V,(q.val).W from(select naturaljoin(k,(Val).RV_values,(Val).SW_values) as val from cogroupRS) q;
/*
Natural Join Query without using the function:
select q.k,unnest(q.RV_values) as V,q.W 
from (
select k,(Val).RV_values,unnest((Val).SW_values) as W 
from cogroupRS c 
where not( (Val).RV_values <@ '{}' or (Val).SW_values <@ '{}') 
) q;
*/

\qecho 'Question 2c'
create type semitype as (k int,V int);
create or replace function semijoin(k int,RV_values int[],SW_values int[]) returns table (val semitype) as
$$
select k,unnest(RV_values) as V 
where not( RV_values <@ '{}' or SW_values <@ '{}');
$$Language SQL;

select k,V from R
except
select (q.val).k,(q.val).V from(select semijoin(k,(Val).RV_values,(Val).SW_values) as val from cogroupRS) q;

/*
Anti Semijoin Query without using the function:
select k,V from R
except
select k,unnest((Val).RV_values) as V from cogroupRS where not( (Val).RV_values <@ '{}' or (Val).SW_values <@ '{}');
*/


\qecho 'Question 3a'
create type cogrpType2 as (
A_values int[],
B_values int[]
);

create or replace view cogroupAB as (
SELECT K, (A_values, B_values)::cogrpType2 as Val
FROM (SELECT q.A as k, ARRAY[q.A] AS A_values
FROM (SELECT distinct a.A FROM A a) q
UNION
SELECT q.K, '{}' AS A_VALUES FROM (SELECT a.A as k FROM A a UNION SELECT b.B FROM B b) q
WHERE q.K NOT IN (SELECT a.A FROM A a)) A_K
NATURAL JOIN 
(SELECT q.B as k, ARRAY[q.B] AS B_values
FROM (SELECT b.B FROM B b) q
UNION
SELECT q.K, '{}' AS B_values FROM (SELECT a.A as k FROM A a UNION SELECT b.B FROM B b) q
WHERE q.K NOT IN (SELECT b.B FROM B b)) B_K);

create or replace function cogrp_intersect(k int,a_values int[],b_values int[]) returns table (K int) as 
$$
select k where a_values=b_values;
$$ Language SQL;

select cogrp_intersect(k,(Val).a_values,(Val).b_values) from cogroupAB order by 1;

/*
intersection query without using the function:
select k from cogroupAB where (Val).a_values=(Val).b_values order by 1;
*/

\qecho 'Question 3b'
create or replace function cogrp_difference(k int,arr_values int[]) returns table (k int) as
$$
select k where arr_values<@'{}';
$$Language SQL;

--A-B
select cogrp_difference(k,(Val).b_values) from cogroupAB order by 1;
/*
setdifference query without using the function:
select k from cogroupAB where (Val).b_values<@'{}' order by 1;
*/

--B-A
select cogrp_difference(k,(Val).a_values) from cogroupAB order by 1;
/*
setdifference query without using the function:
select k from cogroupAB where (Val).a_values<@'{}' order by 1;
*/

\qecho 'Question 4a'
create type sidtype as (sid int);
create type gradesidType as (grade text,courses sidtype[]);
create table courseGrades (cno int,gradeInfo gradesidType[]);
insert into  courseGrades 
with 
S as (select cno,grade, array_agg(row(sid)::sidtype) as courses from enroll group by (cno,grade) ),
C as (select cno, array_agg(row(grade,courses)::gradesidType) as gradeInfo from S group by cno)
select cno,gradeInfo from C;

\qecho 'Question 4b'
CREATE TYPE courseType AS (cno int);
CREATE TYPE gradeCoursesType AS (grade text, courses courseType[ ]);
CREATE TABLE studentGrades(sid int, gradeInfo gradeCoursesType[ ]);
insert into studentGrades
with 
E as (select sid,grade,array_agg(row(cno)::courseType) as courses from courseGrades cg,unnest(cg.gradeInfo) gi,unnest(gi.courses) group by (sid,grade)),
F as (select sid, array_agg(row(grade,courses)::gradeCoursesType) as gradeInfo from E e group by sid)
select sid,gradeInfo from F;

\qecho 'Question 4c'
create table jcourseGrades (courseInfo JSONB);
insert into jcourseGrades 
with 
S as (select cno,grade, array_to_json(array_agg(json_build_object('sid',sid))) as courses from enroll group by (cno,grade)),
C as (select json_build_object('cno',cno, 'gradeInfo', array_to_json(array_agg(json_build_object('grade',grade,'studentids',courses)))) as courseInfo from S group by cno)
select courseInfo from C;

\qecho 'Question 4d'
create table jstudentGrades (studentInfo JSONB);
insert into jstudentGrades
with
E as (select s->'sid' as sid,g->'grade' as grade,array_to_json(array_agg(json_build_object('cno',cg.courseInfo->'cno'))) as courses from jcourseGrades cg,jsonb_array_elements(cg.courseInfo->'gradeInfo') g,jsonb_array_elements(g->'studentids') s 
group by (s->'sid',g->'grade')),
F as (select json_build_object('sid',sid ,'gradeInfo',array_to_json(array_agg(json_build_object('grade',grade,'courses',courses)))) as studentInfo from E group by sid)
select studentInfo from F;

\qecho 'Question 4e'
WITH 
E AS (SELECT (sg.studentinfo->>'sid')::int as sid, (sc->>'cno')::int as cno
FROM jstudentGrades sg ,jsonb_array_elements(sg.studentinfo->'gradeInfo') g ,jsonb_array_elements (g->'courses') sc ),
F AS (SELECT sid , dept , array_to_json(array_agg ( json_build_object( 'cno',cno , 'cname',cname ) )) as courses
FROM E NATURAL JOIN Course
GROUP BY( sid , dept ) )
SELECT sid , sname , array_to_json(ARRAY(SELECT json_build_object('dept',dept , 'courses',courses )
FROM F
WHERE s.sid = F.sid )) AS courseInfo
FROM student s
WHERE sid IN (SELECT sid
FROM major m
WHERE major = 'CS' ) ;

CREATE TABLE student (sid INT, sname TEXT, major TEXT, byear INT);
INSERT INTO student VALUES('100', 'Eric'  , 'CS'     , 1988),('101', 'Nick'  , 'Math'   , 1991),('102', 'Chris' , 'Biology', 1977),('103', 'Dinska', 'CS'     , 1978),('104', 'Zanna' , 'Math'   , 2001),('105', 'Vince' , 'CS'     , 2001);
CREATE TABLE course (cno INT, cname TEXT, dept TEXT);INSERT INTO course VALUES('200', 'PL'      , 'CS'),('201', 'Calculus', 'Math'),('202', 'Dbs'     , 'CS'),('301', 'AI'      , 'CS'),('302', 'Logic'   , 'Philosophy');
CREATE TABLE major (sid INT, major text);INSERT INTO major VALUES ('100','French'),
('100', 'Theater'),('100', 'CS'),('102', 'CS'),('103', 'CS'),('103', 'French'),('104', 'Dance'),('105', 'CS');
CREATE TABLE enroll (sid INT, cno INT, grade TEXT);
insert into enroll values('100','200', 'A'),('100','201', 'B'),('100','202', 'A'),('101','200', 'B'),('101','201', 'A'),('102','200', 'B'),('103','201', 'A'),('101','202', 'A'),('101','301', 'C'),('101','302', 'A'),('102','202', 'A'),('102','301', 'B'),('102','302', 'A'),('104','201', 'D');


WITH E AS (SELECT CAST(sg.studentinfo ->> 'sid' AS INTEGER) AS sid, CAST(c.value ->> 'cno' AS INTEGER) AS cno FROM jstudentGrades sg, JSONB_ARRAY_ELEMENTS(sg.studentinfo -> 'gradeinfo') g, JSONB_ARRAY_ELEMENTS(g.value -> 'courses') c), 

	F AS (SELECT sid, dept, ARRAY_TO_JSON(ARRAY_AGG(JSON_BUILD_OBJECT('cno', cno, 'cname', cname))) AS courses FROM E NATURAL JOIN course GROUP BY(sid, dept)),
	
	G AS (SELECT sid, ARRAY_TO_JSON(ARRAY_AGG(JSON_BUILD_OBJECT('dept', dept, 'courses', courses))) AS courseinfo FROM F GROUP BY sid)
	select * from G;
	
	SELECT sid, sname, courseinfo FROM G NATURAL JOIN student s WHERE s.sid IN (SELECT sid FROM major WHERE major = 'CS');