create database assignment5;

\c assignment5;

\qecho 'Question 3'
select S.sid from student S where (select count(1) from(select cno from course where dept='CS' except select cno from enroll where sid=S.sid) q )=1;

\qecho 'Question 6a'
WITH 
E1 as (select * from major where major='Math'),
E2 as (select * from student where sid in (select distinct sid from E1)),
E3 as (select * from major where major='CS'),
E4 as (select * from E2 where E2.sid in (select distinct sid from E3)),
E5 as (select * from Buys where sid in (select distinct sid from E4))
select bookno,title from Book where bookno in (select bookno from E5);

\qecho 'Question 6b'
WITH
E1 as (select * from cites where bookno in (select bookno from book where price<50)),
E2 as (select distinct e1.citedBookno as bookno from E1 e1 join E1 e2 on (e1.citedBookno=e2.citedBookno and e1.bookno<>e2.bookno))
select sid as s,bookno as b from buys where bookno in (select bookno from E2);


\qecho 'Question 6c'
WITH
E1 as (select sid,bookno,citedBookno from buys T natural join cites C ),
E2 as (select T.sid,C.bookno,C.citedBookno from buys T join cites C on (T.bookno=C.citedBookno) )
select  sid,bookno,citedBookno from E1 natural join E2;

\qecho 'Quesion 6d'
WITH
E1 as (select bookno from book except select citedBookno from cites),
E2 as (select * from buys where bookno in (select bookno from E1))
select distinct sid ,sname from student where sid in (select sid from E2) order by 1;

\qecho 'Question 6e'
WITH
E1 as (select distinct bookno from buys where sid in (select sid from major where major='CS')),
E2 as (select * from book where bookno in (select bookno from E1)),
E3 as (select distinct x1.price from E2 x1 join E2 x2 on (x1.price<x2.price)),
E4 as (select distinct price from E2 except select price from E3 )
select bookno,title from E2 where price in (select price from E4);

\qecho 'Question 6f'
WITH
E1 as (select bookno from book where price>50),
E2 as (select bookno,citedBookno from cites where bookno in (select bookno from E1)),
E3 as (select bookno,citedBookno from cites except select bookno,citedBookno from E2),
E4 as (select distinct citedBookno from cites except select distinct citedBookno from E3)
select bookno,title from book where bookno in (select citedBookno from E4);

\qecho 'Question 6g'
WITH
E1 as (select bookno from book where price>50),
E2 as (select bookno,citedBookno from cites where bookno in (select bookno from E1)),
E3 as (select e1.bookno,B.citedBookno from (select bookno as citedBookno from book) B cross join E1 e1),
E4 as (select bookno,citedBookno from E3 except select bookno,citedBookno from E2)
select bookno, title from book where bookno in (select distinct citedBookno from E4);

\qecho 'Question 6h'
WITH
E1 as (select B1.bookno, B2.bookno as citedBookno from (select bookno from Book) B1 cross join (select bookno from Book) B2),
E2 as (select bookno,citedBookno from E1 except select bookno,citedBookno from cites)
select distinct sid as s, e2.citedBookno as b from buys T natural join E2 e2 order by 1;

\qecho 'Question 6i'
WITH
T2 as (select sid as sid2, bookno from buys),
E1 as (select distinct sid,sid2 from T2 natural join buys), 
E2 as (select distinct S1.sid as s1,S2.sid as s2 from (select sid from student) S1 cross join (select sid from student) S2),
E3 as (select distinct s1,s2 from E2 except select sid, sid2 from E1)
select s1 , s2 from E3 where s1<>s2;

\qecho 'Question 6j'
WITH
T2 as (select * from buys where sid in (select sid from major where major='CS')),
T3 as (select bookno,-1 as sid from book where bookno not in (select bookno from buys)),
T1 as (select bookno,sid from T2 union select bookno,sid from T3 ),
E1 as (select t1.bookno,t2.bookno as bookno2,t2.sid  from T1 t1 cross join T1 t2),
E2 as (select bookno, bookno2, sid from T1 natural join (select bookno as bookno2,sid from T1) t2),
--note here E3 is same as E1 but the bookno and bookno2 order is swapped.
E3 as (select t2.bookno,t1.bookno as bookno2,t2.sid  from T1 t1 cross join T1 t2)
select distinct bookno as b1,bookno2 as b2 from (select * from E1 except select * from E2) q
union
select distinct bookno ,bookno2  from (select * from E3 except select * from E2) q1 order by 1,2;

\c postgres;

drop database assignment5;