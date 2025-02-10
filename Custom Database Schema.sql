use Data_Science_training
go

drop table if exists employee;
drop table if exists branch;
drop table if exists client;
drop table if exists works_with;
drop table if exists branch_supplier;



create table employee(
emp_id int primary key,
first_name varchar(40),
surname varchar(40),
birth_day date,
gender varchar(1),
salary int,
super_id int,
branch_id int
);

create table branch (
branch_id int primary key,
branch_name varchar (40),
mgr_id int,
mgr_start_date date,
foreign key(mgr_id) references employee(emp_id) on delete set null
);

alter table employee
add foreign key(branch_id)
references branch(branch_id)
on delete set null;

alter table employee
add foreign key(super_id)
references employee(emp_id)
on delete set null;

create table client(
client_id int primary key,
client_name varchar(40),
branch_id int,
foreign key(branch_id) references branch(branch_id) on delete set null
); 

create table works_with(
emp_id int,
client_id int,
total_sales int,
primary key(emp_id,client_id),
foreign key(emp_id) references employee(emp_id) on delete cascade,
foreign key(client_id) references client(client_id) on delete cascade
);

create table branch_supplier(
branch_id int,
supplier_name varchar(40),
supplier_type varchar(40),
primary key(branch_id,supplier_name),
foreign key(branch_id) references branch(branch_id) on delete cascade
);

-- inserting information into the employee table
-- coporate
insert into employee values(100, 'Ntokozo', 'Radebe','1995-12-29', 'M', 20000,null,null);
insert into branch values(1,'coporate',100,'2006-11-11');

update employee
set branch_id = 1 
where emp_id = 100;
-- select * from employee;
Update employee
set salary = 40000
where emp_id = 100;
-- select * from branch;

insert into employee values(101, 'James', 'Bond', '1981-05-06', 'M', 11000, 100, 1);

-- Scranton

insert into employee values(102, 'Michael', 'Scott','1975-11-09', 'M', 21000,100,null);
insert into branch values(2,'scranton',102,'2005-07-01');

update employee
set branch_id = 2 
where emp_id = 102;
-- select * from employee;

-- select * from branch;

insert into employee values(103, 'Angela', 'Martin', '1971-06-25', 'F', 7550, 102, 2);
insert into employee values(104, 'Kelly', 'Kapoor', '1980-02-06', 'F', 6300, 102, 2);
insert into employee values(105, 'Stanly', 'Hudson', '1986-05-26', 'M', 7000, 102, 2);

-- Stanford

insert into employee values(106, 'Josh', 'Park','1985-07-09', 'M', 21000,100,null);
insert into branch values(3,'stanford',106,'2006-06-21');

update employee
set branch_id = 3 
where emp_id = 106;
-- select * from employee;

-- select * from branch;

insert into employee values(107, 'Luyanda', 'Radebe', '2005-04-30', 'M', 5550, 106, 2);
insert into employee values(108, 'Amy', 'Benard', '1992-01-26', 'F', 5300, 106, 3);


-- Branch Supplier
insert into branch_supplier values(2, 'Hammer Mill', 'Paper');
insert into branch_supplier values(2, 'Uni-ball', 'Writing Utensils');
insert into branch_supplier values(3, 'Patriot paper', 'Paper');
insert into branch_supplier values(2, 'J.T. Forms & Labels', 'custom forms');
insert into branch_supplier values(3, 'Uni-ball', 'Writing Utensils');
insert into branch_supplier values(3, 'Hammer Mill', 'Paper');
insert into branch_supplier values(3, 'Stamford Lables', 'custom forms');

-- client
insert into client values(400, 'Dunmore HighSchool', 2);
insert into client values(401, 'Lackawana County', 2);
insert into client values(402, 'FedEx', 3);
insert into client values(403, 'John Daly law LLC', 3);
insert into client values(404, 'Scranton  whitepages', 2);
insert into client values(405, 'Times Newspaper', 3);
insert into client values(406, 'FedEx', 2);

-- works with 

insert into works_with values(105, 400, 55000);
insert into works_with values(102, 401, 267000);
insert into works_with values(108, 402, 22500);
insert into works_with values(107, 403, 5000);
insert into works_with values(108, 403, 12000);
insert into works_with values(105, 404, 33000);
insert into works_with values(107, 405, 26000);
insert into works_with values(102, 406, 15000);
insert into works_with values(105, 406, 130000);

-- now to query the database schema

-- lets determine the number of female and male employees

select count(gender), gender
from employee
group by gender;

-- playing with wildcards

-- find any clients who are an LLC
select * 
from client
where client_name like '%LLC';

-- find any branch supplier who are in the label business
select * 
from branch_supplier
where supplier_name like '%label%';

-- find any employee born on May

select *
from employee
where birth_day like '____-05%';

-- find any clients are schools 

select * 
from client
where client_name like '%school%';

-- exploring joins
insert into branch values(4, 'Buffalo', null, null);
select * from branch;

-- find all branches and the names of their managers

select employee.emp_id, employee.first_name, branch.branch_name
from employee
join branch
on employee.emp_id = branch.mgr_id;

select employee.emp_id, employee.first_name, branch.branch_name
from employee
left join branch
on employee.emp_id = branch.mgr_id;

select employee.emp_id, employee.first_name, branch.branch_name
from employee
right join branch
on employee.emp_id = branch.mgr_id;

-- Writing nested queries
-- find all employees who have sold to over 30000 to a single client

select employee.emp_id, employee.first_name, employee.surname
from employee
where employee.emp_id in (
	select works_with.emp_id 
	from works_with
	where works_with.total_sales > 30000
);

-- find all clients who are handled by the branch that michael scott manages
select client_name 
from client
where branch_id in (
	select branch_id  
	from branch
	where mgr_id = 102
);
-- or option 2 below
select client_name 
from client
where branch_id in (
	select branch_id  
	from branch
	where mgr_id in (
		select employee.emp_id
        from employee
        where first_name = 'Michael' and surname = 'Scott'
        )
);

select * from branch;
select * from employee;
select * from client;

-- find all clients who are handled by the branch manager michael scott using CTE
with ETL as(
select  e.first_name, e.surname, b.branch_id
from employee e
join branch b
on e.branch_id = b.branch_id
)

select client_name
from client 
join ETL 
on client.branch_id = ETL.branch_id
where first_name = 'Michael' and surname = 'Scott'

-- or

with ETL as(
select  e.first_name, e.surname, b.branch_id
from employee e
join branch b
on e.branch_id = b.branch_id
),
ETL2 as (
select client.client_name,first_name,surname
from client
join ETL j
on j.branch_id = client.branch_id
)
select client_name
from ETL2 
where ETL2.first_name = 'Michael' and surname = 'Scott'
