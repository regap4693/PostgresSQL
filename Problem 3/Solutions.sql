create database assignment3;


\c assignment3;


\qecho 'Question 1'
create table A (x INTEGER);

insert into A values (1),(2),(3),(4),(5);

select * from A;

select x, sqrt(x) square_root_x, power(x,2) x_squared, power(2,x) two_to_the_power_x, factorial(x) x_factorial, ln(x) logarithm_x from A;
 

\qecho 'Question 2a'
--Use the set A defined before
select * from A;

create table B (x integer);

insert into B values (1),(6),(7),(4),(5);

create table C (x integer);

insert into C values (4), (5);

select * from B;

select * from C;

select not exists (select a.x from A a
intersect
select b.x from B b) as answer;

select not exists (select a.x from A a where a.x in (select b.x from B b)) as answer;


\qecho 'Question 2b'
select exists (select a.x from A a except select b.x from B b) or exists (select b.x from B b except select a.x from A a) as answer;

select exists (select a.x from A a where a.x not in ( select b.x from B b)) or exists (select b.x from B b where b.x not in (select a.x from A a)) as answer;
 

\qecho 'Question 2c'
select not exists (select c.x from C c except (select a.x from A a intersect select b.x from B b))  as answer;

select not exists (select c.x from C c where c.x not in (select a.x from A a where a.x  in ( select b.x from B b)))  as answer;


\qecho 'Question 3'
--create user defined function to calculate distance between two points given their x and y coordinates
create function distance(x1 float,y1 float,x2 float,y2 float)
returns float as
$$
select sqrt(power(x1-x2,2)+power(y1-y2,2))
$$language sql;

create table point (pid integer,x float,y float);

insert into point values (1,0,0),(2,0,1),(3,1,0),(4,0,2),(5,2,2);

select * from point;

-- check the distance between p1 and p2 is less than distance of p1 from any other point and also less than distance of p2 from any other point
select p1.pid as p1,p2.pid as p2 from point p1,point p2 where p1.pid!=p2.pid and distance(p1.x,p1.y,p2.x,p2.y)<=ALL(select distance(p1.x,p1.y,p3.x,p3.y) from point p3 where p3.pid != p1.pid)  and distance(p1.x,p1.y,p2.x,p2.y)<=ALL(select distance(p2.x,p2.y,p3.x,p3.y) from point p3 where p3.pid != p2.pid);


\qecho 'Question 4'
--create table for polynomials P and Q
create table P (coefficient integer, degree integer);

create table Q (coefficient integer, degree integer);

insert into P values (2,2),(-5,1),(5,0);

insert into Q values (3,3),(1,2),(-1,1);

select * from P;

select * from Q;

--the outer query sums up all the coefficients for a degree. These coefficients are obtained after multiplication with other coefficients (in inner query)
select sum(r.coefficient) coefficient, r.degree from (select p.coefficient*q.coefficient coefficient, p.degree+q.degree degree from P p,Q q) r group by r.degree;
 
 
\qecho 'Question 5'
-- created sample M and N matrix
create table M (row integer, colmn integer,value integer);

create table N (row integer, colmn integer,value integer);

insert into M values (1,1,1),(1,2,2),(1,3,3),(2,1,1),(2,2,-10),(2,3,5),(3,1,4),(3,2,0),(3,3,-2);

insert into N values (1,1,2),(1,2,3),(1,3,-3),(2,1,0),(2,2,0),(2,3,0),(3,1,-1),(3,2,5),(3,3,2);

select * from M;

select * from N;

--in matrix multiplication the column elements of first matrix are mutliplied with the respective row elements of second matrix, the inner query here gives this output. It is then grouped (summed) based on the row of first matrix and column of second matrix to fetch the corresponding (row, column) element of the output matrix. 
select q.row1 as row, q.col2 as colmn, sum(q.value1) as matrixmultiplication from (select m.row row1, m.colmn col1 , n.row row2, n.colmn col2 , (m.value*n.value) value1 from M m,N n where m.colmn=n.row) q group by (q.row1 , q.col2) order by 1,2;

--Create relations for upcoming questions:
create table Student (Sid INTEGER primary key,Sname varchar(200));

create table book(bookno integer primary key,title varchar(200), price integer);

create table major(Sid integer,Major varchar(200),Primary Key(Sid,Major),foreign key(sid) references student(sid));

create table cites(bookno integer, citedbookno integer, primary key(bookno,citedbookno),foreign key(bookno) references book(bookno), foreign key(citedbookno) references book(bookno));

create table buys(sid integer, bookno integer, primary key(sid,bookno), foreign key(sid) references student(sid), foreign key(bookno) references book(bookno));

-- Data for the student relation.
INSERT INTO student VALUES(1001,'Jean');
INSERT INTO student VALUES(1002,'Maria');
INSERT INTO student VALUES(1003,'Anna');
INSERT INTO student VALUES(1004,'Chin');
INSERT INTO student VALUES(1005,'John');
INSERT INTO student VALUES(1006,'Ryan');
INSERT INTO student VALUES(1007,'Catherine');
INSERT INTO student VALUES(1008,'Emma');
INSERT INTO student VALUES(1009,'Jan');
INSERT INTO student VALUES(1010,'Linda');
INSERT INTO student VALUES(1011,'Nick');
INSERT INTO student VALUES(1012,'Eric');
INSERT INTO student VALUES(1013,'Lisa');
INSERT INTO student VALUES(1014,'Filip');
INSERT INTO student VALUES(1015,'Dirk');
INSERT INTO student VALUES(1016,'Mary');
INSERT INTO student VALUES(1017,'Ellen');
INSERT INTO student VALUES(1020,'Ahmed');

-- Data for the book relation.

INSERT INTO book VALUES(2001,'Databases',40);
INSERT INTO book VALUES(2002,'OperatingSystems',25);
INSERT INTO book VALUES(2003,'Networks',20);
INSERT INTO book VALUES(2004,'AI',45);
INSERT INTO book VALUES(2005,'DiscreteMathematics',20);
INSERT INTO book VALUES(2006,'SQL',25);
INSERT INTO book VALUES(2007,'ProgrammingLanguages',15);
INSERT INTO book VALUES(2008,'DataScience',50);
INSERT INTO book VALUES(2009,'Calculus',10);
INSERT INTO book VALUES(2010,'Philosophy',25);
INSERT INTO book VALUES(2012,'Geometry',80);
INSERT INTO book VALUES(2013,'RealAnalysis',35);
INSERT INTO book VALUES(2011,'Anthropology',50);

-- Data for the buys relation.

INSERT INTO buys VALUES(1001,2002);
INSERT INTO buys VALUES(1001,2007);
INSERT INTO buys VALUES(1001,2009);
INSERT INTO buys VALUES(1001,2011);
INSERT INTO buys VALUES(1001,2013);
INSERT INTO buys VALUES(1002,2001);
INSERT INTO buys VALUES(1002,2002);
INSERT INTO buys VALUES(1002,2007);
INSERT INTO buys VALUES(1002,2011);
INSERT INTO buys VALUES(1002,2012);
INSERT INTO buys VALUES(1002,2013);
INSERT INTO buys VALUES(1003,2002);
INSERT INTO buys VALUES(1003,2007);
INSERT INTO buys VALUES(1003,2011);
INSERT INTO buys VALUES(1003,2012);
INSERT INTO buys VALUES(1003,2013);
INSERT INTO buys VALUES(1004,2006);
INSERT INTO buys VALUES(1004,2007);
INSERT INTO buys VALUES(1004,2008);
INSERT INTO buys VALUES(1004,2011);
INSERT INTO buys VALUES(1004,2012);
INSERT INTO buys VALUES(1004,2013);
INSERT INTO buys VALUES(1005,2007);
INSERT INTO buys VALUES(1005,2011);
INSERT INTO buys VALUES(1005,2012);
INSERT INTO buys VALUES(1005,2013);
INSERT INTO buys VALUES(1006,2006);
INSERT INTO buys VALUES(1006,2007);
INSERT INTO buys VALUES(1006,2008);
INSERT INTO buys VALUES(1006,2011);
INSERT INTO buys VALUES(1006,2012);
INSERT INTO buys VALUES(1006,2013);
INSERT INTO buys VALUES(1007,2001);
INSERT INTO buys VALUES(1007,2002);
INSERT INTO buys VALUES(1007,2003);
INSERT INTO buys VALUES(1007,2007);
INSERT INTO buys VALUES(1007,2008);
INSERT INTO buys VALUES(1007,2009);
INSERT INTO buys VALUES(1007,2010);
INSERT INTO buys VALUES(1007,2011);
INSERT INTO buys VALUES(1007,2012);
INSERT INTO buys VALUES(1007,2013);
INSERT INTO buys VALUES(1008,2007);
INSERT INTO buys VALUES(1008,2011);
INSERT INTO buys VALUES(1008,2012);
INSERT INTO buys VALUES(1008,2013);
INSERT INTO buys VALUES(1009,2001);
INSERT INTO buys VALUES(1009,2002);
INSERT INTO buys VALUES(1009,2011);
INSERT INTO buys VALUES(1009,2012);
INSERT INTO buys VALUES(1009,2013);
INSERT INTO buys VALUES(1010,2001);
INSERT INTO buys VALUES(1010,2002);
INSERT INTO buys VALUES(1010,2003);
INSERT INTO buys VALUES(1010,2011);
INSERT INTO buys VALUES(1010,2012);
INSERT INTO buys VALUES(1010,2013);
INSERT INTO buys VALUES(1011,2002);
INSERT INTO buys VALUES(1011,2011);
INSERT INTO buys VALUES(1011,2012);
INSERT INTO buys VALUES(1012,2011);
INSERT INTO buys VALUES(1012,2012);
INSERT INTO buys VALUES(1013,2001);
INSERT INTO buys VALUES(1013,2011);
INSERT INTO buys VALUES(1013,2012);
INSERT INTO buys VALUES(1014,2008);
INSERT INTO buys VALUES(1014,2011);
INSERT INTO buys VALUES(1014,2012);
INSERT INTO buys VALUES(1017,2001);
INSERT INTO buys VALUES(1017,2002);
INSERT INTO buys VALUES(1017,2003);
INSERT INTO buys VALUES(1017,2008);
INSERT INTO buys VALUES(1017,2012);
INSERT INTO buys VALUES(1020,2012);

-- Data for the cites relation.

INSERT INTO cites VALUES(2012,2001);
INSERT INTO cites VALUES(2008,2011);
INSERT INTO cites VALUES(2008,2012);
INSERT INTO cites VALUES(2001,2002);
INSERT INTO cites VALUES(2001,2007);
INSERT INTO cites VALUES(2002,2003);
INSERT INTO cites VALUES(2003,2001);
INSERT INTO cites VALUES(2003,2004);
INSERT INTO cites VALUES(2003,2002);

-- Data for the major relation.

INSERT INTO major VALUES(1001,'Math');
INSERT INTO major VALUES(1001,'Physics');
INSERT INTO major VALUES(1002,'CS');
INSERT INTO major VALUES(1002,'Math');
INSERT INTO major VALUES(1003,'Math');
INSERT INTO major VALUES(1004,'CS');
INSERT INTO major VALUES(1006,'CS');
INSERT INTO major VALUES(1007,'CS');
INSERT INTO major VALUES(1007,'Physics');
INSERT INTO major VALUES(1008,'Physics');
INSERT INTO major VALUES(1009,'Biology');
INSERT INTO major VALUES(1010,'Biology');
INSERT INTO major VALUES(1011,'CS');
INSERT INTO major VALUES(1011,'Math');
INSERT INTO major VALUES(1012,'CS');
INSERT INTO major VALUES(1013,'CS');
INSERT INTO major VALUES(1013,'Psychology');
INSERT INTO major VALUES(1014,'Theater');
INSERT INTO major VALUES(1017,'Anthropology');

\qecho 'Question 6a'
create function booksBoughtbyStudent(sid integer)
returns table (bookno integer,title varchar(200), price integer)
as $$
select bookno ,title , price from book where bookno in (select bookno from buys where sid=booksBoughtbyStudent.sid);
$$ Language SQL;

select s.sid,count(B.bookno) from student s,booksBoughtbyStudent(s.sid) B where B.price >40 group by s.sid
union
select s.sid ,0 from student s where not exists (select 1 from booksBoughtbyStudent(s.sid)) order by 1;


\qecho 'Question 6b'
select S1.sid,S1.sname from student S1,booksBoughtbyStudent(S1.sid) B1 group by S1.sid having sum(B1.price)=
(select max(q.price) from (select sum(B.price) price from Student S,booksBoughtbyStudent(S.sid) B group by S.sid) q);


\qecho 'Question 6c'
select s.sid,B.bookno,B.title from student s,booksBoughtbyStudent(s.sid) B where B.price=(select min(B1.price) from booksBoughtbyStudent(s.sid) B1 );


\qecho 'Question 6d'
--too many rows in resullt, hence added count(*) in outer query. Please remove it to obtain the answer
select count(*) from (select s.sid s1,s1.sid s2 from student s,student s1 where s.sid!=s1.sid and (select count(bookno) from booksBoughtbyStudent(s.sid) )=(select count(bookno) from booksBoughtbyStudent(s1.sid))) q;


\qecho 'Question 7'
--Set A - booksBoughtbyStudent(sid)
--set B - books that cost more than $60
create view BooksMorethan60 as select bookno ,title , price from book where price>60;
--NO Quantifier -> A intersect B must be null
select S.sid,S.sname from student S where not exists (select bookno from booksBoughtbyStudent(S.sid) intersect select bookno from BooksMorethan60);


\qecho 'Question 8'
--set A - students who bought book bookno
create function studentsBoughtBook(bookno integer)
returns table (Sid INTEGER,Sname varchar(200))
as $$
select sid,sname from student where sid in (select sid from buys where bookno=studentsBoughtBook.bookno);
$$ Language SQL;

--set B students who have both Math and CS major
create view StudentsCSMath as select sid, sname from student where sid in (select sid from major where major='CS') and sid in (select sid from major where major='Math');

--ALL quantifier -> set B minus A must be null
select B.bookno, B.title from book B where not exists (select sid from StudentsCSMath except select sid from studentsBoughtBook(B.bookno));


\qecho 'Question 9'
--set A - booksBoughtbyStudent(S.sid)
--set B - books that are least expensive:
-- SOME Quantifier -> A intersect B is not null
create view leastPriceBooks as select bookno ,title , price from book where price=(select min(bo.price) from book bo,buys bu where bo.bookno=bu.bookno );
select S.sid,S.sname from student S where exists (select bookno from booksBoughtbyStudent(S.sid) intersect select bookno from leastPriceBooks);


\qecho 'Question 10'
--Set A is booksBoughtbyStudent(s1.sid)
--Set B is booksBoughtbyStudent(s2.sid)
--NOT ONLY quantifier -> A-B is not null
--too many rows in resullt, hence added count(*) in outer query. Please remove it to obtain the answer
select count(*) from (select s1.sid as s1, s2.sid as s2 from student s1,student s2 where s1.sid!=s2.sid and exists (select bookno from booksBoughtbyStudent(s1.sid) except select bookno from booksBoughtbyStudent(s2.sid))) answer;


\qecho 'Question 11'
--set A we use the studentsBoughtBook(bookno) function used Question 8 as set A
--set B Students taking major CS
create view StudentsCS as select sid, sname from student where sid in (select sid from major where major='CS');

select B.bookno, B.title from book B where (select count(1) from (select sid from studentsBoughtBook(B.bookno) intersect select sid from StudentsCS) q )>2;


\qecho 'Question 12'
--set A is booksBoughtbyStudent(sid)
--set B is books more than $35:
create view BooksMorethan35 as select bookno ,title , price from book where price>35;

select S.sid,S.sname from student S where (select (q2.count_35 % 2) from (select count(1) as count_35 from (select bookno from booksBoughtbyStudent(S.sid) intersect select bookno from BooksMorethan35) q) q2)!=0;


\qecho 'Question 13'
--set A we use the studentsBoughtBook(bookno) function used Question 8 as set A
--setB is all students
--since sid is primary key not using distinct to count 3
select B.bookno, B.title from book B where (select count(1) from (select sid from student except select sid from studentsBoughtBook(bookno)) q) =3;


\qecho 'Question 14'
--set A is booksBoughtbyStudent(s1.sid) 
--setB is booksBoughtbyStudent(s2.sid)
--implement not of all and only quantifier
select count(*) from (select s1.sid as s1, s2.sid as s2 from student s1,student s2 where s1.sid!=s2.sid and ((select count(1) from (select bookno from booksBoughtbyStudent(s1.sid) except select bookno from booksBoughtbyStudent(s2.sid)) q)>=1 or ((select count(1) from (select bookno from booksBoughtbyStudent(s2.sid) except select bookno from booksBoughtbyStudent(s1.sid)) q)>=1))) answer;


\qecho 'Question 15'
select s.sid,s.sname from student s where ( select count(1) from book b where b.title !='Networks' and (select count(1) from buys t, book b1 where t.sid = s.sid and t.bookno=b1.bookno and b.title = b1.title)>=1)>=1;


\qecho 'Question 16'
SELECT b.bookno, b.title FROM Book b WHERE (select count(1) FROM Book b1 WHERE (select count(1) FROM Buys t, Major m WHERE t.sid = m.sid and m.major = 'CS' and b1.bookno=t.bookno)=0 and not b.price<=b1.price)=0;

\c postgres;

--Drop database created
DROP DATABASE assignment3;