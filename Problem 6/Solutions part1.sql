-- Solutions B561 2019 Assignment 6

-- Problem 4.a Translate and optimize
select s.sid, s.sname
from   student s
where  s.sid in (select m.sid from major m where m.major = 'CS') AND
       exists (select 1
               from   buys t, cites c, book b1, book b2
               where  s.sid = t.sid and t.bookno = c.citedbookno and
                      c.citedbookno = b1.bookno and c.bookno = b2.bookno and
                      b1.price > b2.price)
order by 1,2;

-- eliminate in and exists

select distinct s.sid, s.sname
from   student s, buys t, cites c, book b1, book b2, major m
where  s.sid = m.sid and m.major = 'CS' and
       s.sid = t.sid and t.bookno = c.citedbookno and
       c.citedbookno = b1.bookno and c.bookno = b2.bookno and
       b1.price > b2.price
order by 1,2;

-- push m.major = 'CS' to major relation

with  CSmajor as (select m.sid, m.major from major m where m.major = 'CS')
select distinct s.sid, s.sname
from   student s, buys t, cites c, book b1, book b2, CSmajor m
where  s.sid = m.sid and
       s.sid = t.sid and t.bookno = c.citedbookno and
       c.citedbookno = b1.bookno and c.bookno = b2.bookno and
       b1.price > b2.price
order by 1,2;

-- form natural join between student and CS major and then with
-- buys 

with  CSmajor as (select m.sid, m.major from major m where m.major = 'CS')
select distinct s.sid, s.sname
from   student s 
       natural join CSmajor m
       natural join buys t, cites c, book b1, book b2
where  t.bookno = c.citedbookno and
       c.citedbookno = b1.bookno and 
       c.bookno = b2.bookno and
       b1.price > b2.price
order by 1,2;

-- join with cites

with  CSmajor as (select m.sid, m.major from major m where m.major = 'CS')
select distinct s.sid, s.sname
from   (student s 
        natural join CSmajor m
        natural join buys t) join cites c on(t.bookno = c.citedbookno), book b1, book b2
where  c.citedbookno = b1.bookno and 
       c.bookno = b2.bookno and
       b1.price > b2.price
order by 1,2;

-- join with book b1 

with  CSmajor as (select m.sid, m.major from major m where m.major = 'CS')
select distinct s.sid, s.sname
from   ((student s 
         natural join CSmajor m
         natural join buys t) 
         join cites c on(t.bookno = c.citedbookno))
         join book b1 on (c.citedbookno = b1.bookno), book b2
where  c.bookno = b2.bookno and
       b1.price > b2.price
order by 1,2;

-- join with book b2 and include b1.price > b2.price

with  CSmajor as (select m.sid, m.major from major m where m.major = 'CS')
select distinct s.sid, s.sname
from   (student s 
        natural join CSmajor m
        natural join buys t) 
        join cites c on (t.bookno = c.citedbookno)
        join book b1 on (c.citedbookno = b1.bookno)
        join book b2 on (c.bookno = b2.bookno and b1.price > b2.price)
order by 1,2;

-- we can now start optimizing
-- we push selections and projections in where possible

with  CS as (select distinct m.sid as sid from major m where m.major = 'CS'),
      T as (select distinct s.sid, s.sname, t.bookno 
            from   student s 
                   natural join CS m
                   natural join buys t),
      B as (select distinct bookno, price from book),
      C as (select c.citedbookno
            from   cites c
                   join B b1 on (c.citedbookno = b1.bookno)
                   join B b2 on (c.bookno = b2.bookno and b1.price > b2.price))
select distinct t.sid, t.sname 
from    T t join C c on (t.bookno = c.citedbookno)
order by 1,2;


-- Problem 4.b
select distinct s.sid, m.major
from   student s, major m
where  s.sid = m.sid and m.major <> 'CS' and
       s.sid = SOME (select t.sid
                     from   buys t, book b
                     where  t.bookno = b.bookno and b.price > 30) and
       s.sid not in (select t.sid
                     from   buys t, book b
                     where  t.bookno = b.bookno and b.price > 50)
order by 1,2;

-- introducing natural join and pushing <> 'CS' condition
-- to major and eliminating = SOME
-- pushing b.price > 30 and b.price > 50

with   notCS as (select m.sid, m.major from major m where m.major <> 'CS'),
       book30 as (select b.bookno, b.title, b.price from book b where price > 30),
       book50 as (select b.bookno, b.title, b.price from book b where price > 50)
select distinct s.sid, m.major
from   student s 
       natural join notCS m
       natural join buys t 
       natural join book30 b
where  s.sid not in (select t.sid
                     from   buys t natural join book50 b)
order by 1,2;

-- replacing not in with NOT EXISTS
with   notCS as (select m.sid, m.major from major m where m.major <> 'CS'),
       book30 as (select b.bookno, b.title, b.price from book b where price > 30),
       book50 as (select b.bookno, b.title, b.price from book b where price > 50)
select distinct s.sid, m.major
from   student s 
       natural join notCS m
       natural join buys t 
       natural join book30 b
where  not exists (select t.sid
                   from   buys t natural join book50 b
                   where  s.sid = t.sid)
order by 1,2;

-- introducing an expression E for the series of natural joins

with   notCS as (select m.sid, m.major from major m where m.major <> 'CS'),
       book30 as (select b.bookno, b.title, b.price from book b where price > 30),
       book50 as (select b.bookno, b.title, b.price from book b where price > 50),
       E as (select s.sid, s.sname, m.major, t.bookno, b.title, b.price
             from student s 
                  natural join notCS m
                  natural join buys t 
                  natural join book30 b)
select distinct e.sid, e.major
from   E e
where  not exists (select t.sid
                   from   buys t natural join book50 b
                   where  e.sid = t.sid)
order by 1,2;

-- eliminating not exists and introducing natural join

with   notCS as (select m.sid, m.major from major m where m.major <> 'CS'),
       book30 as (select b.bookno, b.title, b.price from book b where price > 30),
       book50 as (select b.bookno, b.title, b.price from book b where price > 50),
       E as (select s.sid, s.sname, m.major, t.bookno, b.title, b.price
             from student s 
                  natural join notCS m
                  natural join buys t 
                  natural join book30 b)

select distinct q.sid, q.major
from (select e.*
      from   E e
      except
      select e.*
      from   E e join (buys t natural join book50 b) on e.sid = t.sid) q
order by 1,2;

-- we can now start the optimization
-- we don't need sname, title, and price because of primary key constraints
with   notCS as  (select m.sid, m.major from major m where m.major <> 'CS'),
       book30 as (select b.bookno from book b where price > 30),
       book50 as (select b.bookno from book b where price > 50),
       E as (select s.sid, m.major, t.bookno
             from student s 
                  natural join notCS m
                  natural join buys t 
                  natural join book30 b)
select distinct q.sid, q.major
from (select e.*
      from   E e
      except
      select e.*
      from   E e join (buys t natural join book50 b) on e.sid = t.sid) q
order by 1,2;

-- We can also eliminate s because of foreign key constraint
-- also pushing some more projections down
with   notCS as  (select m.sid, m.major from major m where m.major <> 'CS'),
       book30 as (select b.bookno from book b where price > 30),
       book50 as (select b.bookno from book b where price > 50),
       E as (select m.sid, m.major, r.bookno
             from notCS m
                  natural join (select t.sid, t.bookno from buys t
                                                            natural join book30 b) r)
select distinct q.sid, q.major
from (select e.sid, e.major, e.bookno
      from   E e
      except
      select e.sid, e.major, e.bookno
      from   E e join 
                 (select t.sid from buys t natural join book50 b) p on e.sid = p.sid) q
order by 1,2;

-- introduction of natural join

with   notCS as  (select m.sid, m.major from major m where m.major <> 'CS'),
       book30 as (select b.bookno from book b where price > 30),
       book50 as (select b.bookno from book b where price > 50),
       E as (select m.sid, m.major, r.bookno
             from notCS m
                  natural join (select t.sid, t.bookno from buys t
                                                            natural join book30 b) r)
select distinct q.sid, q.major
from (select e.sid, e.major, e.bookno
      from   E e
      except
      select e.sid, e.major, e.bookno
      from   E e natural join 
                 (select t.sid from buys t natural join book50 b) p ) q
order by 1,2;

-- Problem 4.c
select distinct t.sid, b.bookno
from   buys t, book b
where  t.bookno = b.bookno and
       b.price <= ALL (select b1.price
                       from   buys t1, book b1
                       where t1.bookno = b1.bookno and t1.sid = t.sid)
order by 1,2;

-- replacing <= ALL using NOT EXISTS

select distinct t.sid, b.bookno
from   buys t, book b
where  t.bookno = b.bookno and
       not exists (select b1.price
                   from   buys t1, book b1
                   where t1.bookno = b1.bookno and t1.sid = t.sid and b.price > b1.price)
order by 1,2;

-- introducing joins
select distinct t.sid, b.bookno
from   buys t natural join book b
where  not exists (select b1.price
                   from   buys t1 natural join book b1
                   where  t1.sid = t.sid and b.price > b1.price)
order by 1,2;

-- eliminating not exists
select distinct q.sid, q.tbookno
from   (select t.sid, t.bookno as tbookno, b.* 
        from   buys t natural join book b
        except
        select t.*, b.*
        from   buys t natural join book b, buys t1 natural join book b1
        where  t1.sid = t.sid and b.price > b1.price) q
order by 1,2;

-- introducing join
select distinct q.sid, q.tbookno
from   (select t.sid, t.bookno as tbookno, b.* 
        from   buys t natural join book b
        except
        select t.*, b.*
        from   (buys t natural join book b) join (buys t1 natural join book b1) on
               (t.sid = t1.sid and b.price > b1.price)) q
order by 1,2;

-- We can now start the optimization
with books as (select bookno, price from book)
select distinct q.sid, q.tbookno
from   (select t.sid, t.bookno as tbookno, b.*
        from   buys t natural join books b
        except
        select t.*, b.*
        from   (buys t natural join books b) join (buys t1 natural join books b1) on
               (t.sid = t1.sid and b.price > b1.price)) q
order by 1,2;


-- Problem 4.d
select b.bookno
from   book b
where  not exists (select s.sid
                   from   student s
                   where  s.sid in (select m.sid from major m 
                                    where m.major = 'CS' 
                                    INTERSECT 
                                    select m.sid from major m
                                    where m.major = 'Math') and
                          s.sid not in (select t.sid
                                        from   buys t
                                        where  t.bookno = b.bookno))
order by 1;


select b.bookno
from   book b
where  not exists (select s.sid
                   from   student s
                   where  s.sid in (select m.sid from major m 
                                    where m.major = 'CS' 
                                    INTERSECT 
                                    select m.sid from major m
                                    where m.major = 'Math'
                                    EXCEPT
                                    select t.sid
                                    from   buys t
                                    where  t.bookno = b.bookno))
order by 1;



select b.bookno
from   book b
where  not exists (select q.ssid
                   from   (select m.sid, s.sid as ssid, sname 
                           from   major m, student s
                           where  m.major = 'CS' and s.sid = m.sid
                           INTERSECT 
                           select m.sid, s.* 
                           from   major m, student s
                           where  m.major = 'Math' and s.sid = m.sid
                           EXCEPT
                           select t.sid, s.*
                           from   buys t, student s
                           where  t.bookno = b.bookno and s.sid = t.sid) q)
order by 1;


select r.bookno
from   (select b.*
        from   book b
        except
        select b.*
        from   book b
        where  exists (select q.ssid
                       from   (select m.sid, s.sid as ssid, sname 
                               from   major m, student s
                               where  m.major = 'CS' and s.sid = m.sid
                               INTERSECT 
                               select m.sid, s.* 
                               from   major m, student s
                               where  m.major = 'Math' and s.sid = m.sid
                               EXCEPT
                               select t.sid, s.*
                               from   buys t, student s
                               where  t.bookno = b.bookno and s.sid = t.sid) q)) r
order by 1;


select r.bookno
from   (select b.*
        from   book b
        except
        select q.bookno, q.title, q.price
        from   (select m.sid, s.sid as ssid, sname , b.*
                from   major m, student s, book b
                where  m.major = 'CS' and s.sid = m.sid
                INTERSECT 
                select m.sid, s.*, b.*
                from   major m, student s, book b
                where  m.major = 'Math' and s.sid = m.sid
                EXCEPT
                select t.sid, s.*, b.*
                from   buys t, student s, book b
                where  t.bookno = b.bookno and s.sid = t.sid) q) r
order by 1;

--optimization: primary key bookno, we don't need title and price
-- we also don't need sname
select b.bookno
from  book b
except
select q.bookno
from   (select m.sid, s.sid as ssid , b.bookno
        from   major m, student s, book b
        where  m.major = 'CS' and s.sid = m.sid
        INTERSECT 
        select m.sid, s.sid, b.bookno
        from   major m, student s, book b
        where  m.major = 'Math' and s.sid = m.sid
        EXCEPT
        select t.sid, s.sid, b.bookno
        from   buys t, student s, book b
        where  t.bookno = b.bookno and s.sid = t.sid) q
order by 1;

-- use fk constraint
with   B as (select bookno from book)
select b.bookno
from   B b
except
select q.bookno
from   (select m.sid, b.bookno
        from   (select m.sid from major m where m.major = 'CS') m cross join B b
        INTERSECT 
        select m.sid, b.bookno
        from   (select m.sid from major m where m.major = 'Math')m cross join B b
        EXCEPT
        select t.sid, t.bookno
        from   buys t) q
order by 1;

-- forming subexpression for major in CS and Math
-- we also don't need outer select 


with   B as (select bookno from book),
       M as (select m.sid from major m where m.major = 'CS'
             intersect
             select m.sid from major m where m.major = 'Math')
select b.bookno
from   B b
except
select q.bookno
from   (select m.sid, b.bookno
        from   M m cross join B b
        EXCEPT
        select t.sid, t.bookno
        from   buys t) q
order by 1;




-- Problem 10
create or replace function memberof(x anyelement, S anyarray) returns boolean as
$$
select x = SOME(S)
$$ language sql;

create or replace function setunion(A anyarray, B anyarray) returns anyarray as
$$
select array( select unnest(A) union select unnest(B) order by 1);
$$ language sql;

-- problem 10.a
create or replace function setintersection(A anyarray, B anyarray) returns anyarray as
$$
select array( select unnest(A) intersect select unnest(B) order by 1);
$$ language sql;

--problem 10.b
create or replace function setdifference(A anyarray, B anyarray) returns anyarray as
$$
select array( select unnest(A) except select unnest(B) order by 1);
$$ language sql;

-- Problem 11

create or replace view student_books as
   select distinct s.sid, array(select t1.bookno 
                                from   buys t1 
                                where  t1.sid = s.sid order by bookno) as books
   from   student s order by sid;

select * from student_books;

-- Problem 11.a

create or replace view book_students as
   select b.bookno, array(select t1.sid
                          from   buys t1 
                          where  t1.bookno = b.bookno order by sid) as students
   from   book b order by bookno;

select * from book_students;

-- Problem 11.b 

create or replace view book_citedbooks as
   select b.bookno, array(select c1.citedbookno
                          from   cites c1
                          where  c1.bookno = b.bookno order by citedbookno) as citedbooks
   from   book b order by bookno;

select * from book_citedbooks;

-- Problem 11.c

create or replace view book_citingbooks as
   select b.bookno as bookno, array(select c1.bookno
                                    from   cites c1
                                    where  c1.citedbookno = b.bookno order by bookno) as citingbooks
   from   book b order by bookno;

select * from book_citingbooks;

-- Problem 11.d 

create or replace view major_students as
    select distinct m.major, array(select m1.sid 
                                   from major m1 
                                   where m1.major = m.major) as students
    from   major m order by major;

select * from major_students;

-- Problem 11.e 

create or replace view student_majors as
    select s.sid, array(select m.major from major m where m.sid = s.sid) as majors
    from   student s order by sid;

select * from student_majors;


-- Problem 12.a
-- Find the bookno of each book that is cited by at least
-- one book that cost less than \$50.

select 'Problem 12.a';

select  b.bookno
from    book b
where   exists
        (select 1
         from   book b1, book_citedbooks bc
         where  b1.price < 50 and b1.bookno = bc.bookno and
                memberof(b.bookno,bc.citedbooks))
order by bookno;

-- Problem 12.b 
-- Find the bookno and title of each
-- book that was bought by a student who majors in CS and in Math.

select 'Problem 12.b';

with   CS_and_Math_Students AS (select array(select sid
                                             from   student_majors sm
                                             where  (select array['CS','Math']) <@ sm.majors)
                                                           as students)
select b.bookno, b.title
from   book b
where  exists (select 1
               from   student_books sb, CS_and_Math_students 
               where  memberof(b.bookno, sb.books) and
                      memberof(sb.sid, CS_and_Math_students.students));


Alternatively,

select b.bookno, b.title
from   book b
where  exists
       (select 1
        from   student_books sb, major_students ms1, major_students ms2
        where  ms1.major = 'CS' and ms2.major = 'Math' and 
               memberof(sb.sid,setintersection(ms1.students,ms2.students)) and
               memberof(b.bookno,sb.books))
order by 1,2;

--  Problem 12.c
--  Find the bookno of each book that is cited by exactly one book.

select 'Problem 12.c';

select  bc.bookno
from    book_citingbooks bc
where   cardinality(bc.citingbooks) = 1
order by 1;

--  Problem 12.d
--  Find the sid of each student who bought all books that
--  cost more than\$50.

select 'Problem 12.d';

select  s.sid
from    student_books s
where   array(select bookno from book where price >50) <@ s.books;

-- Problem 12.e
-- Find the sid of each student who bought no book that cost more
-- than \$50.

select 'Problem 12.e';

select  s.sid
from    student_books s
where   not(array(select bookno from book where price >50) && s.books);

-- Problem 12.f
-- Find the sid of each student who bought only books that cost
--  more than \$50.

select 'Problem 12.f';

select  s.sid
from    student_books s
where   s.books <@ array(select bookno from book where price >50);

-- Problem 12.g

-- Find the sids of students who major in ’CS’ and who did not buy any of
-- the books bought by the students who major in ’Math’.

select 'Problem 12.g'

insert into student values(1050, 'Dirk');
insert into major values(1050, 'CS');
insert into buys  values(1050, 3000);


with  books_bought_by_Math_students as
      (select array(select distinct unnest(sb.books)
                    from   student_majors sm, student_books sb
                    where  memberof('Math',sm.majors) and
                           sm.sid = sb.sid order by 1) as books)
select sm.sid 
from   student_majors sm, student_books sb, books_bought_by_Math_students bs
where  sm.sid = sb.sid and
       memberof('CS',sm.majors) and
       not(sb.books && bs.books);

-- Problem 12.h
-- Find sid-bookno pairs $(s,b)$ such that not all books
-- bought by student $s$ are books that cite book $b$.

-- I.e, Find sid-bookno pairs $(s,b)$ such that student s does not
-- only buys books that cite book $b$.

select 'Problem 12.h';

select distinct s.sid, b.bookno 
from   student_books s, book_citingbooks b 
where  not(s.books <@ b.citingbooks) 
order by 1,2;

-- Problem 12.i
-- Find sid-bookno pairs $(s,b)$ such student $s$ only
-- bought books that cite book $b$.

select 'Problem 12.i';

select distinct s.sid, b.bookno 
from   student_books s, book_citingbooks b 
where  s.books <@ b.citingbooks
order by 1, 2;

-- Problem 12.j
-- Find the pairs $(s_1,s_2)$ of sid of students that buy the same books.

select 'Problem 12.j';

select  sb1.sid, sb2.sid
from    student_books sb1, student_books sb2
where   sb1.books <@ sb2.books and sb2.books <@ sb1.books and sb1.sid <> sb2.sid 
order by 1,2;

-- Problem 12.k
-- Find the pairs $(s_1,s_2)$ of sid of students that buy the same
--  number of books

select 'Problem 12.k';

select  sb1.sid, sb2.sid
from    student_books sb1, student_books sb2
where   cardinality(sb1.books) = cardinality(sb2.books) and sb1.sid <> sb2.sid 
order by 1,2;


-- Problem 3.n
--  Find the bookno of each book that cites all but two
--  books.  (In other words, for such a book, there exists only two
--  books that it does not cite.)

select 'Problem 12.l';

select b.bookno
from   book_citedbooks b
where  cardinality( setdifference( array(select b.bookno from book b), b.citedbooks)) = 3;

-- bookno 
--------
--   2010
-- (1 row)

SELECT p.pid, p.pname
  FROM Person p
 WHERE EXISTS (SELECT m.mid
                 FROM Manages m
                WHERE m.eid = p.pid 
                  AND m.mid NOT IN (SELECT w2.pid
                                      FROM Works w1, Works w2
                                     WHERE w1.pid = p.pid 
                                       AND w2.pid = m.mid 
                                       AND w1.salary > w2.salary ))
select * from 									   
select q.pid,q.pname from (select p.* from person p join manages m on (m.eid=p.pid) ) q;

select q.pid,q.pname from (
select p.pid,p.pname,p.city from person p join manages m on (m.mid=p.pid) 
except select p.pid,p.pname,p.city from person p join manages m on (m.mid=p.pid) 
join works w1 on (w1.pid = p.pid) join works w2 on (w2.pid = m.mid and w2.salary>w1.salary)
) q;

array_agg(select (b.*) from book b ,(select unnest(s.books) as bookno) q where q.bookno=b.bookno)


select q.sid,array_agg(b.*) from (select s.sid,unnest(s.books) as bookno  from student_books s where cardinality(books)>=2) q join book b on (b.bookno=q.bookno) group by q.sid ;


with person2 as (select * from person where city='Indianapolis')
select q.pid1,q.pid2,q.pname2 from 
(select p1.pid as pid1,p2.pid as pid2,p1.pname as pname1, p2.pname as pname2,p1.city as city1,p2.city as city2 from person p1 join (select * from person2 where pname='Ellen') p2 on (p1.pid<>p2.pid)
 except select p1.pid as pid1,p2.pid as pid2,p1.pname as pname1, p2.pname as pname2,p1.city as city1,p2.city as city2 from person p1 join (select * from person2 where pname='Ellen') p2 on (p1.pid<>p2.pid) join (select * from works where salary<10000) w on (w.pid =p1.pid)) q







