create database rrp;

\c rrp

\qecho 'Question 1'

create database assignment1;

\c assignment1


create table Sailor (Sid INTEGER Primary key,Sname varchar(200),Rating integer,Age integer);

create table Boat (Bid integer primary key,Bname varchar(200),Color varchar(200));

create table Reserves(Sid integer,Bid integer,Day varchar(200),foreign key(Sid) references Sailor(sid),foreign key(Bid) references Boat(Bid));

select * from sailor;
 
select * from boat;
 
select * from reserves;

INSERT INTO sailor VALUES(22,   'Dustin',       7,      45),(29,   'Brutus',       1,      33),(31,   'Lubber',       8,      55),(32,   'Andy',         8,      25),(58,   'Rusty',        10,     35),(64,   'Horatio',      7,      35),(71,   'Zorba',        10,     16),(74,   'Horatio',      9,      35),(85,   'Art',          3,      25),(95,   'Bob',          3,      63);

INSERT INTO boat VALUES(101,'Interlake','blue'),(102,'Sunset','red'),(103,'Clipper','green'),(104,'Marine','red'),(105,    'SunShine',     'blue');

INSERT INTO reserves VALUES(22,101,'Monday'),(22,102,'Tuesday'),(22,103,'Wednesday'),(31,102,'Thursday'),(31,103,'Friday'),(31,      104,'Saturday'),(64,101,'Sunday'),(64,102,'Monday'),(74,102,'Saturday');

select * from sailor;

select * from boat;
 
select * from reserves;

drop table reserves;
drop table boat;
drop table sailor;

\qecho 'Question 2'
--not null constraint due to primary key does not allow null values in the column, unique constraint due to primary key does not allow dupplicate values:
--table boat created with no primary key constraints
create table Boat (Bid integer ,Bname varchar(200),Color varchar(200));
--null values are inserted in Bid column
INSERT INTO boat VALUES(101,'Interlake','blue'),(null,'Sunset','red');
--dupplicate values are inserted in Bid column
INSERT INTO boat VALUES(101,'Interlake','blue'),(101,'Sunset','red');

drop table boat;

--table boat with primary key constraints 
create table Boat (Bid integer primary key,Bname varchar(200),Color varchar(200));
--the null constraint due to Primary Key does not allow insertion of null values in column Bid:
INSERT INTO boat VALUES(101,'Interlake','blue'),(null,'Sunset','red');
--the unique constraint due to Primary Key, does not allow dupplicate values in column Bid:
INSERT INTO boat VALUES(101,'Interlake','blue'),(101,'Sunset','red');

drop table boat;

--table Sailor with no primary key constraints
create table Sailor (Sid INTEGER, Sname varchar(200),Rating integer,Age integer);
--null values are inserted in Sid column
INSERT INTO sailor VALUES(null,   'Dustin',       7,      45),(29,   'Brutus',       1,      33);
--dupplicate values are inserted in Sid column
INSERT INTO sailor VALUES(29,   'Dustin',       7,      45),(29,   'Brutus',       1,      33);

drop table sailor;

--table Sailor with primary key constraints
create table Sailor (Sid INTEGER Primary Key,Sname varchar(200),Rating integer,Age integer);
--the null constraint due to Primary Key does not allow insertion of null values in column Sid:
INSERT INTO sailor VALUES(null,   'Dustin',       7,      45),(29,   'Brutus',       1,      33);
--the unique constraint due to Primary Key, does not allow dupplicate values in column Sid:
INSERT INTO sailor VALUES(29,   'Dustin',       7,      45),(29,   'Brutus',       1,      33);

drop table sailor;

--Recreate proper tables

create table Sailor (Sid INTEGER Primary key,Sname varchar(200),Rating integer,Age integer);

create table Boat (Bid integer primary key,Bname varchar(200),Color varchar(200));

INSERT INTO boat VALUES(101,'Interlake','blue'),(102,'Sunset','red'),(103,'Clipper','green'),(104,'Marine','red'),(105,    'SunShine',     'blue');

INSERT INTO sailor VALUES(22,   'Dustin',       7,      45),(29,   'Brutus',       1,      33),(31,   'Lubber',       8,      55),(32,   'Andy',         8,      25),(58,   'Rusty',        10,     35),(64,   'Horatio',      7,      35),(71,   'Zorba',        10,     16),(74,   'Horatio',      9,      35),(85,   'Art',          3,      25),(95,   'Bob',          3,      63);

--foreign key constraint- does not allow insertion of values not present in the parent table,does not allow deletion of primary key values in parent table:
--without foreign key constraint on Sid and Bid, the values are inserted in Sid and Bid:
create table Reserves(Sid integer,Bid integer,Day varchar(200));

INSERT INTO reserves VALUES(22,101,'Monday'),(2234,3453,'Tuesday');
INSERT INTO reserves VALUES(22,101,'Monday'),(22,102,'Tuesday');
--without foreign key constraint on Sid and Bid, row is deleted from the referenced parent table:
delete from boat where bid=101;

drop table reserves;

drop table boat;

create table Boat (Bid integer primary key,Bname varchar(200),Color varchar(200));
INSERT INTO boat VALUES(101,'Interlake','blue'),(102,'Sunset','red'),(103,'Clipper','green'),(104,'Marine','red'),(105,    'SunShine',     'blue');


--table reserves with foreign key constraint
create table Reserves(Sid integer,Bid integer,Day varchar(200),foreign key(Sid) references Sailor(sid),foreign key(Bid) references Boat(Bid));
--throws error when inserting values not in parent table
INSERT INTO reserves VALUES(22,101,'Monday'),(2234,3453,'Tuesday');
INSERT INTO reserves VALUES(22,101,'Monday'),(22,102,'Tuesday');
--throws error when deleting row from the referenced parent table:
delete from boat where bid=101;

drop table reserves;

--on using cascade however, the deletion from the parent table is allowed:
create table Reserves(Sid integer,Bid integer,Day varchar(200),foreign key(Sid) references Sailor(sid),foreign key(Bid) references Boat(Bid) ON DELETE CASCADE);

INSERT INTO reserves VALUES(22,101,'Monday'),(22,102,'Tuesday'),(22,103,'Wednesday'),(31,102,'Thursday'),(31,103,'Friday'),(31,      104,'Saturday'),(64,101,'Sunday'),(64,102,'Monday'),(74,102,'Saturday');
delete from boat where bid=105;

delete from sailor where sid =22;-- still throws error since cascade is not defined for Sid column

drop table reserves;
--without foreign key constraint on Bid, values are inserted in Bid but error thrown on Sid which has foreign key defined:
create table Reserves(Sid integer,Bid integer,Day varchar(200),foreign key(Sid) references Sailor(sid));
INSERT INTO reserves VALUES(22,101,'Monday'),(22,13402,'Tuesday');
INSERT INTO reserves VALUES(22,101,'Monday'),(2234,102,'Tuesday');

--recreate proper tables
drop table reserves;
drop table boat;
drop table sailor;


create table Boat (Bid integer primary key,Bname varchar(200),Color varchar(200));
INSERT INTO boat VALUES(101,'Interlake','blue'),(102,'Sunset','red'),(103,'Clipper','green'),(104,'Marine','red'),(105,    'SunShine',     'blue');

create table Sailor (Sid INTEGER Primary key,Sname varchar(200),Rating integer,Age integer);
INSERT INTO sailor VALUES(22,   'Dustin',       7,      45),(29,   'Brutus',       1,      33),(31,   'Lubber',       8,      55),(32,   'Andy',         8,      25),(58,   'Rusty',        10,     35),(64,   'Horatio',      7,      35),(71,   'Zorba',        10,     16),(74,   'Horatio',      9,      35),(85,   'Art',          3,      25),(95,   'Bob',          3,      63);

create table Reserves(Sid integer,Bid integer,Day varchar(200),foreign key(Sid) references Sailor(sid),foreign key(Bid) references Boat(Bid));

INSERT INTO reserves VALUES(22,101,'Monday'),(22,102,'Tuesday'),(22,103,'Wednesday'),(31,102,'Thursday'),(31,103,'Friday'),(31,      104,'Saturday'),(64,101,'Sunday'),(64,102,'Monday'),(74,102,'Saturday');


\qecho 'Question 3 (a)'
select distinct bname from boat;

--distinct not needed since we sid is primary key and is unique in sailor
\qecho 'Question 3 (b)'
select sid,rating from sailor;
 
\qecho 'Question 3 (c)'
select sid,sname,rating from sailor where not (rating>=7 and rating<=9);

\qecho 'Question 3 (d)'
--We use distinct because a boat can be reserved with multiple sailors
select distinct b.bid,b.bname from boat b, reserves r,sailor s where r.bid=b.bid and r.sid=s.sid and b.color='red' and s.rating<9;

\qecho 'Question 3 (e)'
select distinct b.bid,b.bname from boat b,reserves r1, reserves r2 where b.bid=r1.bid and r1.bid=r2.bid and r1.sid<>r2.sid and r1.day='Monday' and r2.day='Tuesday';

\qecho 'Question 3 (f)'
SELECT S.Sid FROM Sailor S WHERE S.Sid NOT IN (SELECT DISTINCT Sid FROM Reserves WHERE Day IN ('Monday', 'Wednesday', 'Thursday'));

\qecho 'Question 3 (g)'
select distinct b.bid,b.bname from boat b, reserves r1,reserves r2 where b.bid=r1.bid and r1.bid=r2.bid and r1.sid<>r2.sid;

\qecho 'Question 3 (h)'
select distinct r1.bid,r2.bid from reserves r1,reserves r2 where r1.sid=r2.sid and r1.bid<>r2.bid order by 1;

\qecho 'Question 3 (i)'
select r.sid,r.bid from reserves r,boat b,sailor s where r.bid=b.bid and r.sid=s.sid and b.color<>'red' and s.rating>7;

\qecho 'Question 3 (j)'
SELECT R.Sid FROM Boat B, Reserves R WHERE B.Bid = R.Bid AND B.Color = 'red' AND R.Sid NOT IN (SELECT DISTINCT S.Sid FROM Sailor S, Reserves R1, Reserves R2, Boat B1, Boat B2 WHERE S.Sid = R1.Sid AND S.Sid = R2.Sid AND R1.Sid = R2.Sid AND R1.Bid <> R2.Bid AND R1.Bid = B1.Bid AND R2.Bid = B2.Bid AND B1.Color = 'red' AND B2.Color = 'red');

\qecho 'Question 3 (k)'
select bid from boat where bid not in (select r1.bid from reserves r1, reserves r2 where r1.bid=r2.bid and r1.sid<>r2.sid);

\c postgres;

--Drop database created
DROP DATABASE assignment1;
--Drop database created
DROP DATABASE rrp;