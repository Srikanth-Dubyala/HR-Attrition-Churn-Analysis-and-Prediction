select * from hr_data;  


with duplicates_cte as 
(
select * ,
row_number()  over (partition by ï»¿Age, Attrition, BusinessTravel, DailyRate, Department, DistanceFromHome, Education, EducationField, EmployeeCount, EmployeeNumber, EnvironmentSatisfaction, Gender, HourlyRate, JobInvolvement, JobLevel, JobRole, JobSatisfaction, MaritalStatus, MonthlyIncome, MonthlyRate, NumCompaniesWorked, Over18, OverTime, PercentSalaryHike, PerformanceRating, RelationshipSatisfaction, StandardHours, StockOptionLevel, TotalWorkingYears, TrainingTimesLastYear, WorkLifeBalance, YearsAtCompany, YearsInCurrentRole, YearsSinceLastPromotion, YearsWithCurrManager) as row_num
from 
hr_data
)
select * from duplicates_cte
where row_num > 1;

-- Renaming the  age column
alter table  hr_data 
Rename column ï»¿Age  to Age ;

select * from hr_data ;

--  No of Employess in each department

select Department,count(EmployeeNumber) as no_of_employess
from hr_data
group by Department
order by no_of_employess desc ;

-- Average income of the people who have churned vs non churned

select Attrition , round(avg(MonthlyIncome * 12 ),2) as avg_yearly_income 
from hr_data
group by Attrition
order by  avg_yearly_income  desc;

select Attrition , round(avg(MonthlyIncome ),2) as avg_monthly_income 
from hr_data
group by Attrition ;

--  the percentage of employees who work overtime ('Yes' in OverTime column) and have churned ('Yes' in Attrition column)

select * from hr_data ;


with percentage_cte as 
(
select Department ,count(EmployeeNumber)  as no_of_employee 
from hr_data
group by Department
),
left_over_time  as
(
select Department ,count(EmployeeNumber)  as no_of_employee_over_time
from hr_data
where Attrition ='Yes' and OverTime = 'Yes'
group by Department
)
select  p.Department,round((l.no_of_employee_over_time * 100)/p.no_of_employee) as percentage 
from percentage_cte p
left join left_over_time  l
on p.Department = l.Department ;

-- 5 job roles with the highest attrition rates

select JobRole,count(Attrition) as no_of_attrition
from hr_data
where Attrition ='Yes'
group by JobRole 
order by  no_of_attrition desc
limit 5 ;


 -- the average years at company, years in current role, years since last promotion, and  years with current manager for employees who have churned vs. those who have not

select * from hr_data ;

select Attrition ,round(avg(YearsAtCompany)) as avg_years_incompany , round(avg(YearsInCurrentRole)) as avg_at_currentrole ,round(avg(YearsSinceLastPromotion)) as avg_years_sincelastpromotion ,round(avg(YearsWithCurrManager)) as avg_years_with_currmanager
from  hr_data
group by Attrition ;

-- Analyze attrition rates by employee age group

select * from hr_data ;


with attrition_cte as
(
select Attrition, count(Attrition) as no_of_attrition,
case
when Age between 18 and 35 then 'Young'
when Age between 36 and 45 then 'Middle-aged'
else 'Old'
end  as age_group
from hr_data 
group by age_group , Attrition)
select age_group , no_of_attrition 
from  attrition_cte
where Attrition ='Yes'
group by age_group
order by no_of_attrition desc  ;

--  average monthly income across different job roles and departments
select *  from hr_data ;

select Department ,JobRole ,round(avg(MonthlyIncome)) as avg_monthly_income
from hr_data
group by Department ,JobRole 
order by  avg_monthly_income desc ;

--  relationship between employees working overtime and their attrition status

select  Attrition ,OverTime ,count(EmployeeNumber) as no_of_employees
from hr_data
group by Attrition ,OverTime  ;

-- distribution of employees by education level within each department.

select * from hr_data ;

with distribution_cte as
(
select Department  ,count(EmployeeNumber) as no_of_employees,
case
when  Education  =  1 then 'Below College'
when  Education  =  2  then 'College'
when  Education  =  3   then 'Bachelor'
when  Education  =  4   then 'Master'
else 'Doctoriate'
end as education_distribution
from hr_data
group by  Department ,education_distribution 
)
select Department ,education_distribution  ,no_of_employees
from distribution_cte 
group by Department ,education_distribution 
order by  Department  ,no_of_employees  desc;


--  average job satisfaction rating for employees based on their tenure at the company (e.g., less than 3 years, 3-5 years, over 5 years)

with statisfaction_cte 
as 
(
select avg(JobSatisfaction) as avg_job_statisfacton,
case
when YearsAtCompany  < 3  then  'less than 3 years of experience ' 
when YearsAtCompany  between 3 and 5   then  '3-5 years of experience'
else 'more than 5 years of experience'
end as employee_experience 
from hr_data
group by  employee_experience 
)
select employee_experience  ,avg_job_statisfacton
from statisfaction_cte
group by employee_experience ;



--  percentage of employees with each marital status (Single, Married, Divorced)

select * from hr_data ;

with martial_status_cte as
( select  MaritalStatus  ,count(EmployeeNumber) as no_of_employees
from hr_data
group by  MaritalStatus 

),
total_cte as
(
select count(*) as total_employee from hr_data
)
select m.MaritalStatus,round((m.no_of_employees * 100 ) /t.total_employee ,2) as percentage
from martial_status_cte m
cross join total_cte t ;

-- average daily rate for employees who have churned versus those who have not

select Attrition ,round(avg(DailyRate),2) as avg_daily_rate
from hr_data 
group by Attrition ;

--  average years an employee has spent with their current manager for both  employees who churned and those who did not

select  Attrition ,round(avg(YearsWithCurrManager),2) as avg_years_withcurrmanager
from hr_data 
group by Attrition ;

--  the number of employees who have not churned within each department

select Department ,count(Attrition) as no_of_employess_churned
from hr_data
where Attrition != 'No'  
group by  Department  ;

-- Analyze the distribution of performance ratings among employees who have churned versus those who have not
select * from hr_data ;

with performance_cte as
(
select Attrition  ,count(EmployeeNumber) as no_of_employees,
case 
when PerformanceRating <= 2 then 'Low'
when PerformanceRating <=3 then  'Average'
else 'High'
end as performance_rating
from hr_data
group by performance_rating , Attrition 
)
select  Attrition ,performance_rating ,no_of_employees
from performance_cte
group by performance_rating ,Attrition 
order by Attrition   ; 

--  the average training times last year for employees who stayed versus those who left

select * from hr_data ;

select Attrition ,round(avg(TrainingTimesLastYear),2) as avg_training_time_last_year
from hr_data
group by  Attrition  ;

-- the job roles with the highest  lowest and  average monthly income.

select JobRole ,max(MonthlyIncome) as highest_monthly_salary ,round(avg(MonthlyIncome)) as avg_monthly_salary ,min(MonthlyIncome) as lowest_monthly_salary
from hr_data
group by JobRole 
order by highest_monthly_salary desc , avg_monthly_salary desc ,lowest_monthly_salary desc;

--  the relationship satisfaction levels for employees based on their marital status and attrition

with satisfaction_cte as
(
select MaritalStatus ,Attrition,
case
when JobSatisfaction <=2 then 'Low JobStatisfaction'
when JobSatisfaction between  2  and 3 then 'Average JobStatisfaction'
else 'High JobStatisfaction'
end as job_statisfaction
from hr_data
group by MaritalStatus ,Attrition,job_statisfaction
)
select MaritalStatus ,Attrition, job_statisfaction
from satisfaction_cte 
group by MaritalStatus ,Attrition, job_statisfaction 
order by MaritalStatus  ;

-- the percentage of employees at each job level


with job_level_cte as
(
select count(*) as total_employees
from hr_data 
),
job_level_percentage_cte as
(
select JobLevel ,count(JobLevel) as no_of_employee
from hr_data
group by JobLevel
)
select j.JobLevel ,round((j.no_of_employee * 100 )/ c.total_employees,2) as percentage_of_employees
from  job_level_cte c 
cross join job_level_percentage_cte j
order by percentage_of_employees desc ;

-- the average age of employees who have churned in each department

select * from hr_data ;

select Department ,avg(Age) as avg_age_of_churned_employees
from hr_data
where Attrition ='Yes' 
group by  Department ;
 
--  the average distance from home for employees who churned versus those who stayed

select * from hr_data ;

select Attrition ,round(avg(DistanceFromHome)) as avg_distance_from_home
from hr_data
group by Attrition ;

-- there specific combinations of department and job role with unusually high attrition rates 
select Department,JobRole ,count(Attrition) as no_of_employee_churned
from hr_data
where Attrition ='Yes'
group by Department ,JobRole
order by  no_of_employee_churned desc
limit 1  ;

--  the attrition rate vary significantly by gender within job roles or departments 

with attrition_total as
(
select count(*) as total_employees
from hr_data
),
attrition_rate_cte as
(
select Gender ,Department ,JobRole ,Attrition,count(EmployeeNumber) as no_of_employees
from hr_data
group by Gender ,Attrition ,Department ,JobRole
)
select c.Gender ,c.Attrition ,c.Department ,c.JobRole,(c.no_of_employees * 100 )/a.total_employees  as attrition_rate
from attrition_total a
cross join attrition_rate_cte  c
order by Gender,attrition_rate desc ;

-- Attrition with churned 

with attrition_total as
(
select count(*) as total_employees
from hr_data
),
attrition_rate_cte as
(
select Gender ,Department ,JobRole ,count(EmployeeNumber) as no_of_employees
from hr_data
where Attrition ='Yes'
group by Gender ,Department ,JobRole
)
select c.Gender  ,c.Department ,c.JobRole,(c.no_of_employees * 100 )/a.total_employees  as attrition_rate
from attrition_total a
cross join attrition_rate_cte  c
order by attrition_rate desc ;

-- Are employees with lower environment satisfaction scores more likely to churn

select * from hr_data ;

select Attrition ,count(EmployeeNumber) as no_of_employees
from hr_data
where EnvironmentSatisfaction =1
group by Attrition ;

--  How does business travel frequency relate to attrition?

with attrition_rate_cte as
(
select count(*) as total_employee
from hr_data 
),
attrition_business_relate_cte as
(
select BusinessTravel ,count(EmployeeNumber) as no_of_employees
from hr_data
where Attrition ='Yes'
group by BusinessTravel
)
select  r.BusinessTravel ,( r.no_of_employees * 100 )/a.total_employee as attrition_rates
from attrition_rate_cte  a
join attrition_business_relate_cte r;

-- What is the churn rate for employees with advanced degrees (Education level 4 or 5) compared to those with lower education levels

with attrition_rate_cte as
(
select count(*) as total_employee
from hr_data 
),
attrition_education_relate_cte as
(
select Education , count(EmployeeNumber) as no_of_employees
from hr_data
where Education = 4 or  5 and Attrition ='Yes'
group by Education
)
select r.Education,( r.no_of_employees * 100 )/a.total_employee as attrition_rates
from attrition_rate_cte  a
join attrition_Education_relate_cte r 
order by attrition_rates desc ;

-- is there a noticeable pattern between stock option levels and employee attrition?
 
 select * from hr_data ;
 
select  StockOptionLevel ,count(EmployeeNumber) as no_of_employee
from hr_data
where Attrition ='Yes'
group by  Attrition,StockOptionLevel 
order by no_of_employee desc ;

-- How does the attrition rate differ between employees hired within the last year and those with  longer tenure?

select * from hr_data ;

with attrition_rate  as
(
select count(*) as total_employees
from  hr_data
),
tenure_cte as 
(
select  Count(EmployeeNumber) as no_of_employees,
case
when YearsAtCompany = 1 then 'Last Year'
else 'Long Tenure'
end as Tenure_distribution
from hr_data
where Attrition ='Yes'
group by Tenure_distribution
)
select t.Tenure_distribution ,(t.no_of_employees * 100 )/a. total_employees as attriton_rate
from attrition_rate a
cross join tenure_cte t;

-- Are certain combinations of job level and education field more prone to churn?

select * from hr_data ;

select EducationField ,JobLevel ,count(EmployeeNumber) as  no_of_employees
from hr_data
where Attrition ='Yes'
group by  EducationField ,JobLevel 
order by no_of_employees desc ;

-- What is the attrition rate for employees with low relationship satisfaction across different departments?

select * from hr_data ;

select Department ,count(EmployeeNumber) as no_of_employess
from hr_data
where Attrition ='Yes' and RelationshipSatisfaction = 1
group by  Department
order by no_of_employess desc ;

-- . How does job involvement impact attrition across age groups

select * from hr_data ;
select distinct JobInvolvement from hr_data ;

with age_group_cte as
(
select count(EmployeeNumber) as no_of_employee,
case when Age Between 18 and 35 then 'Young'
when Age between 36 and 45 then 'Middle-Aged'
else 'Old'
end as age_distribution,
case when JobInvolvement < 2 then 'Low' 
when JobInvolvement  between 2 and 3 then  'Middle'
else 'High'
end as involvement_distribution
from hr_data
where Attrition ='Yes'
group by age_distribution ,involvement_distribution
)
select age_distribution , involvement_distribution,no_of_employee
from age_group_cte 
group by  age_distribution , involvement_distribution
order by no_of_employee desc ;








  







