use hivedb;
--select * from parquet_HREmployee limit 5;

--2. Most employee is working in which department

select department,count(department) as empcount
from parquet_HREmployee
group by department
order by empcount desc;

--3. Highest number of job roles

select jobrole,count(jobrole) as count
from parquet_HREmployee
group by jobrole
order by count desc;

--4. Which gender have higher strength as workforce?

select gender,count(gender) as count
from parquet_HREmployee
group by gender
order by count desc;

--5. Compare the marital status of employee and find the most frequent status.

select maritalstatus,count(maritalstatus) as count
from parquet_HREmployee
group by maritalstatus
order by count desc;

--6. Mostly hired employee have qualification

select education,count(education) as count
from parquet_HREmployee
group by education
order by count desc;

--7. Find the count of employee from which education fields

select educationfield,count(educationfield) as count
from parquet_HREmployee
group by educationfield
order by count desc;

--8. What is the job satisfaction level of employee?

select jobsatisfaction,count(jobsatisfaction) as count
from parquet_HREmployee
group by jobsatisfaction
order by count desc;

--9. Does most of employee do overtime: Yes or No?
select overtime
from (select overtime,count(overtime) as cnt
from parquet_HREmployee
group by overtime
order by cnt desc) as tmp
limit 1;

--10. Find Min & Max Salaried employees.

select * 
from parquet_HREmployee
where income in (select max(income) 
from parquet_HREmployee
union
select min(income)
from parquet_HREmployee);

--11. Does most of the employee do business travel? Find of the employees counts for each category
select businesstravel,count(businesstravel) as count
from parquet_HREmployee
group by businesstravel
order by count desc;

--12. Find the AVG Income of graduate employee.

select avg(income) as avg_slry_graduates
from parquet_HREmployee
where education not in ('Below College','College');

--13. Find the employee qualification receiving salary lower than equal to avg. salary of all employee.

select distinct(education)
from parquet_HREmployee h1,(select avg(income) as avg_slry from parquet_HREmployee) h2
where h1.income < h2.avg_slry;

--14. When does the employee have highest chance of promotion in terms of working year?

select if(YearsSinceLastPromotion<5,'<5',if(YearsSinceLastPromotion>10,'10+','5-10')), count(*) as Count from hremployee group by YearsSinceLastPromotion order by Count desc;

--15. Highest attrition is in which department? Display this in % percentage as well.

select department,sum(case when attrition = 'Yes' then 1 else 0 end),count(*) as emp_count_dept, sum(case when attrition = 'Yes' then 1 else 0 end)*100/sum(count(*)) over () as attr_rate
from parquet_HREmployee 
group by department
order by attr_rate desc;

--16. Show marital status of Person having highest attrition rate.

select MaritalStatus,Attrition,count(*) as count from hremployee 
where MaritalStatus is not null and Attrition == 'Yes'
group by MaritalStatus, Attrition 
order by MaritalStatus;
