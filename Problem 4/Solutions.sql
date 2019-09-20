create database assignment4;

\c assignment4;

create table Student(sid int, sname text, major text);

create table course(cno int, cname text, total int, max int);

create table prerequisite(cno int, prereq int);

create table hastaken(sid int, cno int);

create table enroll(sid int, cno int);

create table waitlist(sid int, cno int, position int);

\qecho 'Question 1'

--create insert and delete triggers for the relations:
--STUDENT - INSERT trigger
create or replace function student_constraint_pk() returns trigger as
$$
Begin
If new.sid in (select sid from student) then
raise exception 'Primary Key unique constraint violation- sid already exists';
elsif new.sid is null then
raise exception 'Primary Key null constraint violation- sid cannot be null';
end if;
return new;
end;
$$ language 'plpgsql';

create trigger check_student_pk
before insert on student 
for each row execute procedure student_constraint_pk();

insert into student values (1,'Raji','CS');
insert into student values (2,'Sam','CS');
--inserting dupplicate sid values throws pk violation error
insert into student values (2,'Raj','DS');
--inserting null values in sid throws pk violation error
insert into student values (null,'Raj','DS');

--STUDENT - DELETE
create or replace function student_constraint_fk() returns trigger as
$$
Begin
if old.sid in (select sid from hastaken) then
delete from hastaken where sid=old.sid;
end if;
if old.sid in (select sid from enroll) then
delete from enroll where sid=old.sid;
end if;
if old.sid in (select sid from waitlist) then
delete from waitlist where sid=old.sid;
end if;
return old;
end;
$$ language 'plpgsql';

create trigger check_student_fk
before delete on student 
for each row execute procedure student_constraint_fk();

--insert test data
insert into hastaken values (1,100);
insert into enroll values (1,200);
insert into waitlist values (2,100,10);

select * from hastaken;
select * from enroll;
select * from waitlist;

-- on deleting from the parent table student, the record is also removed from the child tables by the delete trigger on Student
delete from student where sid=1;

select * from student;

select * from hastaken;--will not be deleted once trigger hastaken_constraint_delete_trig is defined


select * from enroll;



select * from waitlist;


-- delete on the sid not in any of the child tables is also implemented successfully
insert into student values (3,'Tom Riddle','Dark Arts');

delete from student where sid=3;

select * from student;
 

--COURSE - INSERT:
create or replace function course_constraint_pk() returns trigger as
$$
Begin
If new.cno in (select cno from course) then
raise exception 'Primary Key unique constraint violation- cno already exists';
elsif new.cno is null then
raise exception 'Primary Key null constraint violation- cno cannot be null';
end if;
return new;
end;
$$ language 'plpgsql';

create trigger check_course_pk
before insert on course 
for each row execute procedure course_constraint_pk();

--set up test data
insert into course values(100,'ADC',60,63);

insert into course values(200,'Big Data',40,53);

select * from course;
 

insert into student values (1,'Raji','CS');

insert into student values (3,'Tom Riddle','Witchcraft');

insert into course values (300,'Defense against Dark Arts',80,100);


select * from student;



select * from course;


--PK-unique constraint and null constraint violations are handled
insert into course values (null,'random',10,10);

insert into course values (200,'random',10,10);


--COURSE - DELETE:
create or replace function course_constraint_fk() returns trigger as
$$
Begin
if old.cno in (select cno from hastaken) then
delete from hastaken where cno=old.cno;
end if;
if old.cno in (select cno from enroll) then
delete from enroll where cno=old.cno;
end if;
if old.cno in (select cno from waitlist) then
delete from waitlist where cno=old.cno;
end if;
if old.cno in (select cno from prerequisite) then
delete from prerequisite where cno=old.cno;
end if;
if old.cno in (select prereq from prerequisite) then
delete from prerequisite where prereq=old.cno;
end if;
return old;
end;
$$ language 'plpgsql';

create trigger check_course_fk
before delete on course 
for each row execute procedure course_constraint_fk();

--set up test data
insert into hastaken values (1,100);

insert into enroll values (1,200);

insert into waitlist values (2,100,10);

insert into prerequisite values (100,200);

insert into prerequisite values (300,100);

insert into prerequisite values (300,200);


select * from hastaken;
 

select * from prerequisite;



select * from enroll;
 

select * from waitlist;



select * from course;


-- on deleting cno=100 from course, the foreign keys in child tables prerequisite (on cno and prereq columns), hastaken, enroll and waitlist is also deleted:

delete from course where cno=100;

select * from course;



select * from prerequisite;



select * from hastaken;



select * from enroll;



select * from waitlist;


--PREREQUISITE - INSERT:

create or replace function prerequisite_constraint_fk() returns trigger as
$$
Begin
If new.cno not in (select cno from course) then
raise exception 'Foreign Key constraint violation on cno- cno does not exist in parent table course';
elsif new.prereq not in (select cno from course) then
raise exception 'Foreign Key constraint violation on prereq- cno does not exist in parent table course';
end if;
return new;
end;
$$ language 'plpgsql';

create trigger check_prerequisite_fk
before insert on prerequisite 
for each row execute procedure prerequisite_constraint_fk();

--For reference:
select * from course;



select * from student;


--error is thrown if value in cno or prereq or both in the newly inserted row is not present in the parent table course:

insert into prerequisite values (100000,200);

insert into prerequisite values (200,10000);

insert into prerequisite values (200000,10000);


--PREREQUISITE - DELETE- No effect needed since there is no PK mentioned explicitly for this table

create or replace function prerequisite_constraint_delete() returns trigger as
$$
Begin
return old;
end;
$$ language 'plpgsql';

create trigger prerequisite_constraint_delete_trig
before delete on prerequisite 
for each row execute procedure prerequisite_constraint_delete();


-- HASTAKEN - INSERT:
create or replace function hastaken_constraint_fk() returns trigger as
$$
Begin
If new.cno not in (select cno from course) then
raise exception 'Foreign Key constraint violation on cno- cno does not exist in parent table course';
elsif new.sid not in (select sid from student) then
raise exception 'Foreign Key constraint violation on sid- sid does not exist in parent table student';
end if;
return new;
end;
$$ language 'plpgsql';

create trigger check_hastaken_fk
before insert on hastaken 
for each row execute procedure hastaken_constraint_fk();

--error thrown when user tries to insert values in Sid and cno that are not present in the student and course relation respectively:

insert into hastaken values (10000,200);

insert into hastaken values (2,10000);

insert into hastaken values (200000,10000);

--HASTAKEN- do not allow delete on hastaken sunce it is table stores history (as mentioned in Piazza by professor):

create or replace function hastaken_constraint_delete() returns trigger as
$$
Begin
return null;
end;
$$ language 'plpgsql';

create trigger hastaken_constraint_delete_trig
before delete on hastaken 
for each row execute procedure hastaken_constraint_delete();

-- ENROLL - INSERT:
create or replace function enroll_constraint_fk() returns trigger as
$$
Begin
If new.cno not in (select cno from course) then
raise exception 'Foreign Key constraint violation on cno - cno does not exist in parent table course';
elsif new.sid not in (select sid from student) then
raise exception 'Foreign Key constraint violation on sid - sid does not exist in parent table student';
end if;
return new;
end;
$$ language 'plpgsql';

create trigger check_enroll_fk
before insert on enroll 
for each row execute procedure enroll_constraint_fk();

insert into enroll values (10000,200);

insert into enroll values (200,10000);

insert into enroll values (200000,10000);

--valid inserts are allowed:
insert into enroll values (2,200);


--ENROLL - DELETE- No effect since there is no PK mentioned explicitly for this table

create or replace function enroll_constraint_delete() returns trigger as
$$
Begin
return old;
end;
$$ language 'plpgsql';

create trigger enroll_constraint_delete_trig
before delete on enroll 
for each row execute procedure enroll_constraint_delete();

-- WAITLIST - INSERT:
create or replace function waitlist_constraint_fk() returns trigger as
$$
Begin
If new.cno not in (select cno from course) then
raise exception 'Foreign Key constraint violation on cno - cno does not exist in parent table course';
elsif new.sid not in (select sid from student) then
raise exception 'Foreign Key constraint violation on sid - sid does not exist in parent table student';
end if;
return new;
end;
$$ language 'plpgsql';

create trigger check_waitlist_fk
before insert on waitlist 
for each row execute procedure waitlist_constraint_fk();

--error thrown when user tries to insert values in Sid and cno that are not present in the student and course relation respectively:

insert into waitlist values (20000,200,10);

insert into waitlist values (2,200000,10);

insert into waitlist values (20000,200000,10);

--WAITLIST - DELETE- No effect since there is no PK mentioned explicitly for this table
create or replace function waitlist_constraint_delete() returns trigger as
$$
Begin
return old;
end;
$$ language 'plpgsql';

create trigger waitlist_constraint_delete_trig
before delete on waitlist 
for each row execute procedure waitlist_constraint_delete();

\qecho 'Question 2 sub part 1 and 2'
create or replace function enroll_prereq_count() returns trigger as $$
begin
If exists(select prereq from prerequisite where cno=new.cno except select cno from hastaken where sid=new.sid) 
then raise exception 'Cannot enroll - prerequisites for the course are not taken';
end if;
if (select c.total=c.max from course c where c.cno=new.cno)
then 
-- initial value of waitlist is 0 
insert into waitlist values (new.sid,new.cno,0);
--waitlist is updated to max+1
update waitlist set position= (select max(position) from waitlist where cno=new.cno)+1 where cno=new.cno and sid=new.sid;
raise notice 'Cannot enroll - class is full, you have been waitlisted';
-- return null to prevent execution of the statements that follow (i.e. increment total and insert in enroll is skipped)
return null;
end if;
update course set total=total+1 where cno=new.cno;
return new;
end;
$$ language 'plpgsql';

create trigger check_enroll_prereq_count
before insert on enroll
for each row execute procedure enroll_prereq_count();

-- course 300 is a prerequisite of course 400 and student 1 has taken course 300 only
insert into course values (400,'ADC','0',30);

insert into prerequisite values(400,300);

insert into hastaken values (1,300);


select * from enroll;


select * from prerequisite;



select * from hastaken;
 


select * from course;


--student 1 is enrolled in course 400 since the student has taken prerequisite 300

insert into enroll values (1,400);

select * from enroll;
 

select * from prerequisite;
 

select * from hastaken;


-- the total count for the course 400 is incremented by 1
select * from course;



insert into enroll values (2,400);


--add another prerequisite for course 400 , now 400 has 300 and 200 as prerequisite
insert into prerequisite values (400,200);


-- insertion of same record this time leads to error since the student has not taken the course 200.
insert into enroll values (1,400);

-- courses without prerequisites (cno 200) are also inserted and total is incremented:
--please ignore the initial value of 40 for course 200
insert into enroll values (1,200);

select * from course;

--delete initially inserted test data
delete from enroll where sid=1 and cno=400;

--update the course 400 with total=max to test waitlisting
update course set total =max where cno=400;

select * from course;


--both students 1  and 2 have the taken the prerequisites 200 and 300 in order to enroll for course 400
insert into hastaken values (1,200);

insert into hastaken values (2,200);

insert into hastaken values (2,300);

insert into course values (100,'EDA',20,30);

select * from waitlist;



--course 400 is full (course manually updated before)
insert into enroll values (1,400);


--hence the student is waitlisted for the course
select * from waitlist;


insert into enroll values (2,400);

select * from waitlist;
 

--the course total for course 400 is not incremented
select * from course;

-- student not enrolled
select * from enroll;

   
--non full courses:
--the courses that are not full are still inserted in enroll and course has its total incremented:
insert into enroll values (1,100);

--course total incremented:
select * from course;


-- waitlist not changed:
select * from waitlist;

--student enrolled:

select * from enroll;


\qecho 'Question 2 sub part 3'
--when a student drops course by deleting from the waitlist, the waitlist position of others above that student in that course must reduce
create function waitlist_delete() returns trigger as $$
begin
update waitlist set position=position-1 where cno=old.cno and position > old.position;
return null;
end;
$$ language 'plpgsql';

create trigger waitlist_delete_trig
after delete on waitlist
for each row execute procedure waitlist_delete();
--student 3 satisfies the prerequisites for cno 400
insert into hastaken values (3,200),(3,300);

insert into enroll values (3,400);

--student 3 waitlisted 
select * from waitlist;


--delete on waitlist for student 2- reduces the position for the student 3 by 1 while postion for student 1 remains the same.
delete from waitlist where cno=400 and sid=2;

select * from waitlist;


--if a student drops by deleting from enroll, 
	--the person at waitlist position 1 for that course must get enrolled
	--subsequently he must also be removed from the wailtist
	--the position of other waitlisted students for that course must be reduced by 1 (taken care of by the above trigger for wailtist delete)
	--if no student on waitlist then total in reduced by 1 for that course
	
create or replace function enroll_delete() returns trigger as $$
begin
update course set total=total-1 where cno=old.cno;
if exists(select 1 from waitlist where cno=old.cno) then 
insert into enroll values ((select sid from waitlist where cno=old.cno and position=1),old.cno);
delete from waitlist where cno=old.cno and position=1;
end if;
return null;
end;
$$ language 'plpgsql';

create trigger enroll_delete_trig
after delete on enroll
for each row execute procedure enroll_delete();

--setup test data to test
update course set total=total-1 where cno=400;

insert into enroll values (2,400);

select * from enroll;

select * from course;

select * from waitlist;


--delete the enrollment of sid 2 in cno 400
delete from enroll where sid =2 and cno=400;


--sid 1 at wailtist position 1 is now enrolled in cno 400
select * from enroll;
 

--sid 3 at wailtist position 2 is now at position 1
select * from waitlist;


--course total is unchanged
select * from course;
 

--set up test case for no waitlist- delete sids for all enrolled students
delete from enroll where cno=400 and sid =1;

-- on deleting the last enrolled student sid 3
delete from enroll where sid =3 and cno=400;

select * from enroll;
 


select * from waitlist;


-- the total for the course is reduced by 1
select * from course;


\qecho 'Question 3'

-- create a relation mimicking the materialized view major
--account for the initial data by doing a select along with create
create table Major as select distinct s.major, (select count(1) FROM student s1 where s1.major = s.major and s1.sid in (select sid from enroll)) as numberOfStudents from student s;

--major must be checked when a new student comes in. Insert if their major is not listed in this view, update if the major is already in the table.
--technically we do not need insert trigger for student for this since we are having a foreign key to student, a student cannot be enrolled unless they have been recorded in student table, so when a new student comes in , he will not be enrolled just yet, so we handle during inserts to enroll table

--check if any major can now be inserted since the new student who is in the major is now enrolled
create or replace function major_insert_enroll() returns trigger as $$
begin
--assuming a student belongs to only one major
--if a student has not enrolled at all in any course then they will not be accounted for in the count in major, and hence we need to update or insert into major
if new.sid not in (select sid from enroll) then
if not exists (select 1 from major where major in (select major from student where sid=new.sid)) then
insert into major values ((select major from student where sid=new.sid),1);
else
update major set numberOfStudents=numberOfStudents+1 where major in (select major from student where sid=new.sid);
end if;
end if;
return new;
end;
$$ language 'plpgsql';

create trigger major_insert_enroll_trig
before insert on enroll
for each row execute procedure major_insert_enroll();

--if the student in the major is leaving the enrollment table then the count must be reduced 
create function major_delete_enroll() returns trigger as $$
begin
if old.sid not in (select sid from enroll) then
update major set numberOfStudents=numberOfStudents-1 where major in (select major from student where sid =old.sid);
--student was the last of the major then delete major
if (select numberOfStudents from major where major in (select major from student where sid =old.sid))=0 then
delete from major where major=(select major from student where sid =old.sid);
end if;
end if;
return null;
end;
$$ language 'plpgsql';

create trigger major_delete_enroll_trig
after delete on enroll
for each row execute procedure major_delete_enroll();

--if a record is deleted from student then count reduced for the respective major - if the student is enrolled (if cascade delete is not allowed this trigger is not applicable)
create or replace function major_delete_student() returns trigger as $$
begin
if old.sid in (select sid from enroll) then
update major set numberOfStudents=numberOfStudents-1 where major=old.major;
--student was the last of the major then delete major
if (select numberOfStudents from major where major=old.major)=0 then
delete from major where major=old.major;
end if;
end if;
return old;
end;
$$ language 'plpgsql';

create trigger major_delete_student_trig
before delete on student
for each row execute procedure major_delete_student();


--testing

select * from student;


select * from enroll;



select * from major;



insert into student values (4,'John','HCI');


-- nothing inserted in major since sid 4 is not enrolled yet
select * from major;


insert into enroll values (4,100);


--sid 4 is enrolled and major recorded in major table
select * from enroll;



select * from major;


--students enrolls for another course , count remains the same since count keeps track of no. of students
insert into enroll values (4,200);

select * from major;


insert into enroll values (3,100);

select * from major;


insert into student values (5,'Akash Sethi','HCI');

select * from student;



insert into enroll values (5,100);

-- count increased by 1 for HCI since sid 5 newly enrolled
select * from major;



select  * from enroll;


delete from enroll where sid=4 and cno=100;

--sid 4 dropped course 4 major count not changed
select * from major;
 
--sid 4 drops last course 200, major HCI count reduces by 1
delete from enroll where sid=4 and cno=200;

select * from major;
 

--records for sid 4 have dropped from enroll as well
select * from enroll;


--last student in the course drops his last and only enrollment, major is dropped:
delete from enroll where sid=5 and cno=100;

select * from major;
 
select * from student;


-- insert test data
insert into enroll values (4,100);
insert into enroll values (4,200);

select * from enroll;
 


select * from major;



--sid 5 is not enrolled hence the major count is not reduced since it does not account for that
delete from student where sid=5;

select * from student;

select * from major;


-- sid 4 is enrolled and accounted for in the major count hence on dropping sid 4 his major HCI gets dropped because he is the last student in that major.
delete from student where sid=4;

select * from major;

\c postgres;

drop database assignment4;
