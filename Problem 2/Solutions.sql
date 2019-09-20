create database assignment2;

\c assignment2;

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

\qecho 'Question 1a'
select distinct b.bookno,b.title from book b,buys bs, major m where b.price>10 and b.bookno = bs.bookno and bs.sid = m.sid and (m.major = 'CS' or m.major='Math');


\qecho 'Question 1b'
select b.bookno,b.title from book b where b.price>10 and b.bookno in (select bs.bookno from buys bs where bs.sid in (select m.sid from major m where m.major = 'CS' or m.major='Math'));


\qecho 'Question 1c'
select b.bookno,b.title from book b where b.price>10 and b.bookno =some (select bs.bookno from buys bs where bs.sid =some (select m.sid from major m where m.major = 'CS' or m.major='Math'));


\qecho 'Question 1d'
select b.bookno,b.title from book b where b.price>10 and exists (select bs.sid from buys bs where b.bookno=bs.bookno and exists(select m.sid from major m where m.major = 'CS' or m.major='Math' and m.sid=bs.sid));


\qecho 'Question 2a'

select distinct s.sid,s.sname from student s
except
--below query gives students who bought books more than $10
select distinct s.sid,s.sname from student s,buys bs, book b where s.sid = bs.sid and bs.bookno = b.bookno and b.price>10;
--result includes all students who are did not books at all and who bought books less than $10

\qecho 'Question 2b'
select sid,sname from student where sid not in (select sid from buys where bookno not in (select bookno from book where price<=10));


\qecho 'Question 2c'
--!=ALL makes sure the resultant sids does not belong to anyone who bought books more than $10
select sid,sname from student where sid !=ALL (select sid from buys where bookno !=ALL (select bookno from book where price<=10));

\qecho 'Question 2d'
select s.sid, s.sname from student s where not exists (select bs.sid from buys bs where bs.sid =s.sid and not exists (select b.bookno from book b where b.price<=10 and b.bookno=bs.bookno));


\qecho 'Question 3a'
--book b gives info for one book and book b1 gives info for another book that cite citedbookno who's info is given by book b2. Here price of both b1 and b is expected to be more than $15 where both book b1 and b cite book b2 
select distinct b2.bookno, b2.title, b2.price from cites c,cites c1,book b,book b1,book b2 where  b.bookno=c.bookno and b1.bookno=c1.bookno and c1.citedbookno=c.citedbookno and b2.bookno=c.citedbookno and c1.bookno!=c.bookno and b.price>15 and b1.price>15;


\qecho 'Question 3b'
select bookno, title, price from book where bookno in (select c.citedbookno from cites c where c.citedbookno in (select c1.citedbookno from cites c1 where c1.bookno!=c.bookno and c1.bookno in (select bookno from book where price>15) ) and c.bookno in (select bookno from book where price>15))  ;


\qecho 'Question 3c'
select b.bookno, b.title, b.price from book b where exists (select c.citedbookno from cites c where c.citedbookno=b.bookno and exists (select c1.citedbookno from cites c1 where c1.bookno!=c.bookno and exists (select bookno from book where price>15 and bookno =c1.bookno) and c1.citedbookno=c.citedbookno ) and exists (select bookno from book where price>15 and c.bookno=bookno));

\qecho 'Question 4a'
select distinct s.sid, s.sname from student s,major m,buys b,book bk where s.sid = m.sid and s.sid =b.sid and b.bookno= bk.bookno and m.major='CS' and bk.price>=ALL(select price from buys);

\qecho 'Question 4b'
--sid belongs to a CS student. And one who buys a book that has price more than all other books
select sid, sname from student where sid in (select sid from major where major='CS') and sid in (select sid from buys where bookno in (select bookno from book where price>=ALL(select price from buys)));

\qecho 'Question 5'
--any book that has price less than all other books cannot cite resultant citedbookno
select bookno,title from book where bookno in (select citedbookno from cites where bookno not in (select bookno from book where price<=All(select price from book)));


\qecho 'Question 6'
--The first inner query ensures that the student has bought some book. The second inner query ensures the student does not have more than one major. The third inner query ensures that the student has not bought books that are less than $10. (that will make sure that have bought all that cost more than $10)
select sid, sname from student where sid in (select bs.sid from buys bs where bs.sid  in (select m.sid from major m where not exists(select m1.sid from major m1 where m1.sid=m.sid and m1.major!=m.major )) and not exists (select sid from buys where sid=bs.sid and bookno in (select bookno from book where price<=10)));


\qecho 'Question 7'
--here the query 'select b.bookno from book b where not exists ( select price from book where price<b.price and bookno!=b.bookno )' gives the lowest priced book which is used twice in the below query to obtain the second lowest 
select b1.bookno,b1.title from book b1 where not exists (select price from book where price<b1.price and bookno!=b1.bookno and bookno not in (select b.bookno from book b where not exists ( select price from book where price<b.price and bookno!=b.bookno )) ) and b1.bookno not in (select b.bookno from book b where not exists ( select price from book where price<b.price and bookno!=b.bookno ));


\qecho 'Question 8'
--The last two subqueries ensure that the student has not bought a book more than $75. Last third inner query ensures the student does not belong to this group. and has bought book more than $75. The first subquery ensures student not one of this group.
select sid,sname from student where sid not in (select distinct sid from buys where bookno in (select bookno from book where price>75) and sid not in(select s.sid from buys s where exists (select bookno from book where price>75 and bookno not in (select bookno from buys b1 where b1.sid=s.sid))));


\qecho 'Question 9'
--The last two subqueries ensure that the student has not bought a book more than $75. Last third inner query ensures the student does not belong to this group and has bought book more than $75. i.e. has not bought book that is not $75
select sid,sname from student where sid in (select distinct sid from buys where bookno in (select bookno from book where price>75) and sid not in(select s.sid from buys s where exists (select bookno from book where price>75 and bookno not in (select bookno from buys b1 where b1.sid=s.sid))));


\qecho 'Question 10'
--last inner query gives books that belong to a student. Last second inner query ensures price is highest of all books of that student
select bs.sid,bs.bookno from buys bs where bs.bookno in (select b.bookno from book b where bs.bookno=b.bookno and b.price>= ALL(select price from book where bookno in (select bookno from buys where sid=bs.sid)));

\qecho 'Question 12'
--added an extra count(*) to the actual query since there are 42 records and was causing the next query to throw error. Please remove that to see the records.
--outer query finds pairs of students with common books. Inner query is the same as outer query and also checks that common book here is not same as common book in outer query.
select count(*) from (select bs.sid,bs1.sid from buys bs,buys bs1 where bs.bookno=bs1.bookno and bs.sid !=bs1.sid and not exists( select bs2.sid,bs3.sid from buys bs2,buys bs3 where bs2.bookno=bs3.bookno and bs2.sid=bs.sid and bs3.sid=bs1.sid and bs2.bookno!=bs.bookno)) as result;

\qecho 'Question 13'
create view bookAtLeast30 as (select b.bookno,b.title,b.price from book b where price>=30);
--the first inner query finds student who has bought book less than $30 and second inner query is also the same except that this book is not same as the one in the previous query (total 2 books less than $30)
select s.sid,s.sname from student s where s.sid in (select b.sid from buys b where b.bookno not in (select bookno from bookAtLeast30) and exists (select b1.sid from buys b1 where b1.sid=b.sid and b1.bookno!=b.bookno and b1.bookno not in (select bookno from bookAtLeast30)));

drop view bookAtLeast30;


\qecho 'Question 14'
--select query same as Q13, only the view definition changes.
WITH bookAtLeast30 as (select b.bookno,b.title,b.price from book b where price>=30)
select s.sid,s.sname from student s where s.sid in (select b.sid from buys b where b.bookno not in (select bookno from bookAtLeast30) and exists (select b1.sid from buys b1 where b1.sid=b.sid and b1.bookno!=b.bookno and b1.bookno not in (select bookno from bookAtLeast30)));


\qecho 'Question 15a'
create function citedByBook (b integer)
returns table (bookno integer,title varchar(200),price integer) as
$$ select bookno, title, price from book where bookno in (select citedbookno from cites where bookno =b) $$ language sql;
--outer query gives books cited by 2001, inner query gives books cited by 2002 plus ensures these books are same
select c.bookno,c.price from citedByBook (2001) c where exists ( select c1.bookno from citedByBook (2002) c1 where c1.bookno=c.bookno );


\qecho 'Question 15b'
--first inner query looks for cited books by outer query book b, second inner query is the same plus ensures cited book is different from that in the first query. Final resultant book is one that does not satisfy this.i.e. cites only one book
select b.bookno,b.title from book b where not exists (select c.bookno from citedByBook(b.bookno) c  where exists (select bookno from citedByBook(b.bookno) where bookno!=c.bookno));

\c postgres;

--Drop database created
DROP DATABASE assignment2;