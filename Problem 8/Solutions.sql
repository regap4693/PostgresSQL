create database assignment8
\c assignment8
\qecho 'Question 1'
/*
Graph is considered to be directed graph as mentioned in the problem statement
Only if strongly connected graphs they are declared biconnected, if weakly connected then not biconnected
*/
DROP TABLE IF EXISTS TC;
CREATE TABLE TC(source integer, target integer);
DROP TABLE IF EXISTS graph;
create table graph (source int, target int);
insert into graph values (2,1),(1,4),(4,2),(1,2),(2,4),(4,1);

CREATE OR REPLACE FUNCTION new_TC_pairs()
RETURNS TABLE (source integer, target integer)AS
$$
(SELECT p1.source, p2.target
FROM TC p1 JOIN TC p2 ON (p1.target=p2.source))
EXCEPT
(SELECT source, target
FROM TC);
$$ language sql;

CREATE OR REPLACE FUNCTION biConnected()
RETURNS Boolean AS
$$
DECLARE
vertex int;
subv int;
--default the graph to being a biconnected graph, changed to false if articulation vertex is found
RES boolean:=True;
BEGIN
--for every vertex in the graph(testing if vertex is an articulation vertex)
for vertex in (select source from graph union select target from graph)
loop
--create a subgraph without the vertex
drop table if exists subgraph;
create table subgraph(source int, target int);
insert into subgraph (select * from graph except select * from graph where source=vertex except select * from graph where target=vertex);
--construct the ancestor descendant pairs for the subgraph
---TC FUNCTION
DROP TABLE IF EXISTS TC;
CREATE TABLE TC(source integer, target integer);
INSERT INTO TC SELECT * FROM Subgraph;
WHILE EXISTS (SELECT * FROM new_TC_pairs())
LOOP
INSERT INTO TC SELECT * FROM new_TC_pairs();
END LOOP;
---TC FUNCTION
--- check if the subgraph is connected
DROP TABLE IF EXISTS VISITED;
CREATE TABLE VISITED(vert integer);
for subv in (select source from subgraph union select target from subgraph)
loop
insert into visited values(subv);
--check if all nodes except the visited ones are reachable from subv
--eliminate visited since all other vertices are already checked against the visited
if exists(select source from subgraph union select target from subgraph except select vert from visited except select source from TC where target=subv )
then RES:=FALSE;
return RES;
end if;
if exists(select source from subgraph union select target from subgraph except select vert from visited except select target from TC where source=subv )
then RES:=FALSE;
return RES;
end if;
end loop;
END LOOP;
return RES;
END;
$$ language plpgsql;

select * from biConnected();

\qecho 'Question 2'
/*
Please do select * from SG; to get the final result
*/
--Example 1
DROP TABLE IF EXISTS PC;
create table PC (parent int,child int);
insert into PC values (1,3),(1,9),(10,1),(10,2),(8,10),(8,7),(7,100),(7,20),(44,8),(44,6);
--Example 2
DROP TABLE IF EXISTS PC;
create table PC (parent int,child int);
insert into PC values (1,2),(1,3),(1,4),(2,5),(2,6),(3,7),(5,8);

DROP TABLE IF EXISTS TC;
CREATE TABLE TC(source integer, target integer);

CREATE OR REPLACE FUNCTION sameGeneration()
RETURNS void AS
 $$
 DECLARE
 height int;
 BEGIN
 --create a relation GEN_num which holds for each vertex- the max path length from the root
 DROP TABLE IF EXISTS GEN_num;
 CREATE TABLE Gen_num(person integer,levelno integer);
 --set the root to 0 and all other nodes at 1
 INSERT INTO Gen_num (SELECT child,1 FROM PC);
 INSERT INTO Gen_num (SELECT parent,0 FROM PC except select person,0 from gen_num);
 
 --find all parent child relation
 DROP TABLE IF EXISTS TC;
 CREATE TABLE TC(source integer, target integer);
 INSERT INTO TC SELECT * FROM PC;

 WHILE EXISTS (SELECT * FROM new_TC_pairs())
 LOOP
 -- for every child in an iteration increment its level by 1, meaning the child has a parent at one more further generation above
 update Gen_num set levelno=levelno+1 where person in (select target from new_TC_pairs());
 INSERT INTO TC SELECT * FROM new_TC_pairs();
 END LOOP;
 
 DROP TABLE IF EXISTS SG;
 CREATE TABLE SG(person1 integer,person2 integer);
 -- ouput vertices at same levels meaning they are of same generation
 INSERT INTO SG (select g1.person, g2.person from GEN_num g1,GEN_num g2 where g1.levelno=g2.levelno);
 END;
 $$ language plpgsql;
 
 CREATE OR REPLACE FUNCTION new_TC_pairs()
RETURNS TABLE (source integer, target integer)AS
$$
-- note TC joins with PC Graph and not with TC so we can identify the genre correctly
(SELECT TC.source, PC.child
FROM TC JOIN PC ON (TC.target = PC.parent))
EXCEPT
(SELECT source, target
FROM TC);
$$ language sql;

select * from sameGeneration();
--select * from gen_num;
select * from SG;

\qecho 'Question3'
--Example1
DROP TABLE IF EXISTS partsubpart;
DROP TABLE IF EXISTS parts;
create table partsubpart (pid int,sid int,quantity int);
create table parts(pid int, weight int);
insert into partsubpart values (1,2,4),(1,3,1),(3,4,1),(3,5,2);
insert into parts values (2,5),(4,50),(5,3);
--Example 2
DROP TABLE IF EXISTS partsubpart;
DROP TABLE IF EXISTS parts;
create table partsubpart (pid int,sid int,quantity int);
create table parts(pid int, weight int);
insert into partsubpart values (1,2,4),(1,3,1),(3,4,1),(3,5,2),(3,6,3),(6,7,2),(6,8,3);
insert into parts values  (2,5),(4,50),(5,3),(7,6),(8,10);

create or replace function aggregatedweight(p int) returns int as
$$
DECLARE
c int;
aggwt int:=0;
BEGIN
if p in (select pid from parts )
then return(select weight from parts where pid=p);
else 
for c in (select sid from partsubpart where pid=p)
LOOP
aggwt=aggwt+aggregatedweight(c)*(select quantity from partsubpart where pid=p and sid=c);
END LOOP;
return aggwt;
end if;
END;
$$Language 'plpgsql';

--Example 1
select * from aggregatedweight(1);
--Example 2
select aggregatedweight(6);

\qecho 'Question 4'
--Example 1
--DROP TABLE IF EXISTS arr_next;
--create table arr_next (arr int[]);
DROP TABLE IF EXISTS A;
create table A (x int);
insert into A values (10),(22),(31),(4),(8),(9),(2),(5),(7);

--Example 2
DROP TABLE IF EXISTS A;
create table A (x int);
insert into A values (1),(2),(3),(4);

--DROP TABLE IF EXISTS arr_next;
--create table arr_next (arr int[]);

CREATE OR REPLACE FUNCTION array_sort (arr anyarray) RETURNS anyarray AS 
$$
SELECT ARRAY(SELECT unnest(arr) ORDER BY 1);
$$ LANGUAGE SQL;

create or replace function gen_set(intial int[]) returns void as 
$$
DECLARE
anew int[];
w int;
BEGIN
DROP TABLE IF EXISTS new_set;
create table new_set (setarr int[]);
for w in (select distinct x from A except select unnest(intial) as uword)
loop
anew:=array_append(intial,w);
anew:=array_sort(anew);
if (anew not in (select setarr from arr_next)) 
then
insert into new_set values (anew);
end if;
end loop;
END;
$$Language 'plpgsql';

create or replace function superSetsOfSet(X int[]) returns table (setarrays int[]) as
$$
DECLARE
def int[]:='{}';
i int:=0;
y int[];
BEGIN
if not(X <@ array(select A.x from A))
then return query select def;
else
DROP TABLE IF EXISTS arr_prev;
create table arr_prev (setarr int[]);
DROP TABLE IF EXISTS arr_inital;
create table arr_inital (setarr int[]);
DROP TABLE IF EXISTS arr_next;
create table arr_next (setarr int[]);
insert into arr_next select X;
perform gen_set(X);
insert into arr_next select setarr from new_set;
while exists(select setarr from arr_next except select setarr from arr_inital)
loop
insert into arr_inital (select setarr from arr_next except select setarr from arr_inital);
for y in (select setarr from arr_next except select setarr from arr_prev)
loop
perform gen_set(y);
insert into arr_next select setarr from new_set;
end loop;
insert into arr_prev (select setarr from arr_inital except select setarr from arr_prev);
end loop;
return query select setarr from arr_next;
end if;
END;
$$ Language 'plpgsql';

--Example 1
--select * from gen_set('{}');
select * from superSetsOfSet('{}');
select * from superSetsOfSet('{5,9}');
select * from superSetsOfSet('{13,9}');
--Example 2
select supersetsofset('{}');
select supersetsofset('{1}');
select supersetsofset('{1,3}');
select supersetsofset('{1,2,3}');

\qecho 'Question 5'
/*
if you note carefully the functions used here are similar to that of Question4
*/
--Example 1
drop table if exists document;
create table document(doc int, words text[]);
insert into document values(1,'{"a","b","c"}'),(2,'{"d","e","f","a"}'),(3,'{"b","a","c","b"}'),(4,'{"b","a","h"}');

--Example 2
drop table if exists document;
create table document(doc int, words text[]);
insert into document values (7,'{"C","B","A"}'),(1,'{"A","B","C"}'),(8,'{"B","A"}'),(4,'{"B","B","A","D"}'),(2,'{"B","C","D"}'),(6,'{"A","D","G"}'),(3,'{"A","E"}'),(5,'{"E","F"}');

create or replace function checkset(ssinitial text[],t int) returns void as 
$$
DECLARE
tfreqset2 text[]:='{}';
ssnew text[]:=ssinitial;
freq int:=0;
w text;
BEGIN
DROP TABLE IF EXISTS tfreqset2;
create table tfreqset2 (setarr text[]);
for w in (select distinct q.uword from (select unnest(words) as uword from document) q except select unnest(ssinitial) as uword)
loop
ssnew:=array_append(ssnew,w);
ssnew:=array_sort(ssnew);
select count(distinct doc) into freq from document where ssnew<@(words);
if (freq>=t and ssnew not in (select setarr from tfreset_next)) 
then
insert into tfreqset2 values (ssnew);
end if;
ssnew:=ssinitial;
end loop;
END;
$$Language 'plpgsql';

CREATE OR REPLACE FUNCTION array_sort (arr anyarray) RETURNS anyarray AS 
$$
SELECT ARRAY(SELECT unnest(arr) ORDER BY 1)
$$ LANGUAGE SQL;

create or replace function frequentSets(t int) returns table (setarrays text[]) as
$$
DECLARE
i int:=0;
y text[];
BEGIN
DROP TABLE IF EXISTS tfreset_prev;
create table tfreset_prev (setarr text[]);
DROP TABLE IF EXISTS tfreset_inital;
create table tfreset_inital (setarr text[]);
DROP TABLE IF EXISTS tfreset_next;
create table tfreset_next (setarr text[]);
if t<=(select count(distinct doc) from document)
then insert into tfreset_next select '{}';
end if;
perform checkset('{}',t);
insert into tfreset_next select setarr from tfreqset2;
while exists(select setarr from tfreset_next except select setarr from tfreset_inital)
loop
insert into tfreset_inital (select setarr from tfreset_next except select setarr from tfreset_inital);
for y in (select setarr from tfreset_next except select setarr from tfreset_prev)
loop
perform checkset(y,t);
insert into tfreset_next select setarr from tfreqset2;
end loop;
insert into tfreset_prev (select setarr from tfreset_inital except select setarr from tfreset_prev);
end loop;
return query select setarr from tfreset_next;
END;
$$ Language 'plpgsql';

--Example 1
select * from frequentSets(2);
--select * from checkset('{"a"}',2);
--Example 2
select * from frequentSets(1);

\qecho 'Question6'
/*
if you note carefully the functions used here are similar to that of Question2
*/

--Example 1
DROP TABLE IF EXISTS graph;
create table graph (source int, target int);
insert into graph values (5,2),(5,0),(4,0),(4,1),(2,3),(3,1);

--Example 2
DROP TABLE IF EXISTS graph;
create table graph (source int, target int);
insert into graph values (1,2),(1,3),(2,4),(3,4),(2,5),(4,5),(3,6),(4,6);

DROP TABLE IF EXISTS TC;
CREATE TABLE TC(source integer, target integer);

CREATE OR REPLACE FUNCTION new_TC_pairs()
RETURNS TABLE (source integer, target integer)AS
$$
-- note TC joins with Graph and not with TC so we can identify the genre correctly
(SELECT TC.source, Graph.target
FROM TC JOIN Graph ON (TC.target = Graph.source))
EXCEPT
(SELECT source, target
FROM TC);
$$ language sql;

CREATE OR REPLACE FUNCTION topologicalSort()
RETURNS table (ordered_nodes int) AS
 $$
 DECLARE
 height int;
 BEGIN
 --create a relation GEN_num which holds for each vertex- the max path length from the root
 DROP TABLE IF EXISTS GEN_num;
 CREATE TABLE Gen_num(node integer,levelno integer);
 --set the root to 0 and all other nodes at 1
 INSERT INTO Gen_num (SELECT target,1 FROM Graph);
 INSERT INTO Gen_num (SELECT source,0 FROM Graph except select node,0 from Gen_num);
 
 --find all parent child relations
 DROP TABLE IF EXISTS TC;
 CREATE TABLE TC(source integer, target integer);
 INSERT INTO TC SELECT * FROM Graph;

 WHILE EXISTS (SELECT * FROM new_TC_pairs())
 LOOP
 -- for every child in an iteration increment its level by 1, meaning the child has a parent at one more further generation above
 update Gen_num set levelno=levelno+1 where node in (select target from new_TC_pairs());
 INSERT INTO TC SELECT * FROM new_TC_pairs();
 END LOOP;
 
 return query  select q.node from (select distinct * from gen_num) q order by q.levelno,q.node;
 END;
 $$ language plpgsql;

 select * from topologicalSort();
 
 \qecho 'Question 7'
 /*
 Prims Algorithm
 */
DROP TABLE IF EXISTS weightedgraph;
create table weightedgraph (source int, target int,cost int);
insert into weightedgraph values (  1,  2,  5),	(  2,  1,  5),	(  1,  3,  3),	(  3,  1,  3),	(  2,  3,  2),	(  3,  2,  2),	(  2,  5,  2),	(  5,  2,  2),	(  3,  5,  4),	(  5,  3,  4),	(  2,  4,  8),	(  4,  2,  8);

create or replace function minimumSpanningTree() returns table (s int,t int) as 
$$
BEGIN
drop table if exists graphnodes;
create table graphnodes(node int,insubgraph int);
--the insubgraph column has 1 if the node is in spanning tree, 0 otherwise, initially all nodes are set to 0
insert into graphnodes (select source,0 from weightedgraph union select target,0 from weightedgraph);

drop table if exists spantree;
create table spantree(source int, target int);

--we take the minimum node as the first vertex for our spanning tree:
update graphnodes set insubgraph=1 where node in (select min(node) from graphnodes);
while exists(select * from graphnodes where insubgraph=0)
loop
insert into spantree select wg.source, wg.target from weightedgraph wg where wg.cost in (
	select min(cost) from weightedgraph where source in (select node from graphnodes where insubgraph=1) and target not in(select node from graphnodes where insubgraph=1) union
	select min(cost) from weightedgraph where target in (select node from graphnodes where insubgraph=1) and source not in(select node from graphnodes where insubgraph=1)) 
		and ((source in (select node from graphnodes where insubgraph=1) and target not in (select node from graphnodes where insubgraph=1)) or (target in (select node from graphnodes where insubgraph=1) and source not in (select node from graphnodes where insubgraph=1)));

	update graphnodes set insubgraph=1 where node in (select source from spantree union select target from spantree);
end loop;
return query select * from spantree;
END;
$$ Language 'plpgsql';
select * from minimumspanningtree();

\qecho 'Question 8'
drop table if exists data;
create table data (index int,value int);
 insert into data values (    1 ,   3),(    2 ,   1),(    3 ,   2),(    4 ,   0),(    5 ,   7),(    6 ,   8),(    7 ,   9),(    8 ,  11),(    9 ,   1),(   10 ,   3);
 
 create or replace function heap_insert() returns table (ind int,val int) as
 $$
 DECLARE
 data_row data%rowtype;
 parent_ind int;
 child_ind int;
 child int;
 parent int;
 BEGIN
 drop table if exists heap_data;
 create table heap_data (index int,value int);
 for data_row in (select * from data order by 1)
 loop
 insert into heap_data values (data_row.index,data_row.value);
 child_ind:=data_row.index;
 child:=data_row.value;
 if child_ind%2=0 
 then
	parent_ind:=child_ind/2;
 else
	parent_ind:=(child_ind-1)/2;
 end if;	 
 select value into parent from heap_data where index=parent_ind;
 while (parent>child)
 loop
 update heap_data set value=child where index=parent_ind;
 update heap_data set value=parent where index=child_ind;
 child_ind:=parent_ind;
 if child_ind%2=0
 then
	parent_ind:=child_ind/2;
 else
	parent_ind:=(child_ind-1)/2;
 end if;
 select value into parent from heap_data where index=parent_ind; 
 end loop;
 end loop;
 return query select * from heap_data order by 1;
 END;
 $$ Language 'plpgsql';
 
 create or replace function heap_extract() returns int as 
 $$
 DECLARE
 root int;
 last_leaf int;
 parent_ind int;
 parent int;
 child_ind1 int;
 child1 int;
 child_ind2 int;
 child2 int;
 BEGIN
 select value into root from heap_data where index=1;
 select value into last_leaf from heap_data where index in (select max(index) from heap_data);
 update heap_data set value=last_leaf where index=1;
 delete from heap_data where index in (select max(index) from heap_data);
 parent_ind=1;
 parent=last_leaf;
 child_ind1=2*parent_ind;
 child_ind2=(2*parent_ind)+1;
 select value into child1 from heap_data where index=child_ind1;
 select value into child2 from heap_data where index=child_ind2;
 while(parent>child1 or parent>child2)
 loop
 if child1<child2 or child2 is null
 then 
 update heap_data set value=child1 where index=parent_ind;
 update heap_data set value=parent where index=child_ind1;
 parent_ind=child_ind1;
 elsif child2<=child1 or child1 is null
 then
 update heap_data set value=child2 where index=parent_ind;
 update heap_data set value=parent where index=child_ind2;
 parent_ind=child_ind2; 
 end if;
 child_ind1=2*parent_ind;
 child_ind2=2*parent_ind+1;
 select value into child1 from heap_data where index=child_ind1;
 select value into child2 from heap_data where index=child_ind2;
 end loop;
 return root;
 END;
 $$ LANGUAGE 'plpgsql';
 
 select * from heap_insert();
 
 create or replace function heapsort() returns table (ind int, val int) as 
 $$
 DECLARE
 root int;
 ind int:=1;
 x heap_data%rowtype;
 BEGIN
 PERFORM heap_insert();
 drop table if exists sortedData;
 create table sortedData (ind int,val int); 
 for x in (select * from heap_data)
 loop
 root:=heap_extract();
 insert into sortedData values (ind,root);
 ind:=ind+1;
 end loop;
 return query select * from sortedData;
 END;
 $$ Language 'plpgsql';
 
 select * from heapsort();
 select * from sortedData;
--select * from heap_insert();
--select * from heap_extract();


\qecho 'Question 9'
/*
have refered the C++ backpropogation code in the link https://www.geeksforgeeks.org/m-coloring-problem-backtracking-5/
*/
--not 3 colorable
drop table if exists graph;
create table graph (source int, target int);
insert into graph values (1,2),(1,4),(4,3),(2,3),(3,4),(5,1),(5,2),(5,4),(5,3),(5,6),(6,1),(2,6);
--3 colorable
drop table if exists graph;
create table graph (source int, target int);
insert into graph values (1,2),(1,4),(4,3),(2,3);
drop table if exists graph;
create table graph (source int, target int);
insert into graph values (5,1),(5,4),(4,3),(5,3),(5,2),(1,2),(3,2);

create or replace function threecolorable() returns boolean as 
$$
DECLARE
ret boolean:=false;
total_nodes int;
x int;
i int:=1;
BEGIN
--color3_graph holds the final colors assigned to each vertex
drop table if exists color3_graph;
create table color3_graph (pk int,vertex int,color_vertex int);
--take all vertices in graph
for x in (select source from graph union select target from graph)
loop
--initially set color to 0 (0 stands for no color)
insert into color3_graph values(i,x,0);
i:=i+1;
end loop;
select count(*) into total_nodes  from (select source from graph union select target from graph) q;
ret:=find_graph(0,total_nodes);
return ret;
END;
$$ LANGUAGE 'plpgsql';

create or replace function find_graph(current_pk int,total_nodes int) returns boolean as
$$
DECLARE
node int;
colored int;
BEGIN
--if all vertices are colored then return true
select count(*) into colored from (select distinct vertex from color3_graph where color_vertex!=0) q;
if colored=total_nodes then return true; end if;

select vertex into node from color3_graph where pk=current_pk;
--1,2,3 are the three colors Red, Green and Blue respectively
for c in 1..3 
loop
--check if the parents or the children of the node does not have the same color
if not exists (select c intersect 
					select color_vertex from color3_graph 
							where vertex in (select source from graph where target =node) 
								or vertex in (select target from graph where source =node))
then 
update color3_graph set color_vertex=c where pk=current_pk;
--recursively check if it can be colored
if find_graph(current_pk+1,total_nodes) then return true; end if;
--if not then remove the color
update color3_graph set color_vertex=0 where pk=current_pk;
end if;
end loop;
return false;
END;
$$ LANGUAGE 'plpgsql';

select * from threecolorable();

\c postgres;
drop database assignment8;


