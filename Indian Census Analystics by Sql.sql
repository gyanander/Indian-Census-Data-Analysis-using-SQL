
use Project1
select * from Project1.dbo.Data1
select * from Project1.dbo.Data2

--1...Find the Number of rows into our datasets.

select COUNT(*) from Project1..Data1
select COUNT(*) from Project1..Data2

--2...find the details of Dataset for jharkhand and Bihar
use Project1
select * from data1 where state in('jharkhand','bihar')

--3..Find the Total Population of india

select * from Project1..Data2
select sum(population) as population from Project1..Data2

--4.. Find the avg growth of Population 

select avg(growth)*100 as avg_growth from Project1..Data1;
select state,avg(growth)*100 as avg_growth from Project1..Data1 group by State;

--5.. Find the avg sex ratio of the Dataset.

select state,avg(sex_ratio)as avg_sex_ratio from Project1..Data1 group by State
select state,round(avg(sex_ratio),0)as avg_sex_ratio from Project1..Data1 group by State order by avg_sex_ratio desc;

--6.. Find the avg literacy rate of the dataset

select state,round(avg(Literacy),0)as avg_literacy_ratio from Project1..Data1 group by State order by avg_literacy_ratio desc;
select state,round(avg(Literacy),0)as avg_literacy_ratio from Project1..Data1 group by State having round(avg(literacy),0)>90 order by avg_literacy_ratio desc;

--7..Find Top 3 state showing highest growth ratio

select top 3 state,avg(growth)*100 as avg_growth from Project1..Data1 group by State order by avg_growth desc;

--8..Find bottom 3 state showing lowest sex ratio

select top 3 state,round(avg(sex_ratio),0)as avg_sex_ratio from Project1..Data1 group by State order by avg_sex_ratio asc;

--9..Find Top 3 States having max Sex_Ratio (By window function)---

select State,Sex_Ratio from (select * ,DENSE_RANK()over(order by Sex_Ratio desc) as rnk from Data1 )t where t.rnk<=5;


--10..Find Top 3 and Bottom 3 States in literacy(in new table)

drop table if exists #topstates;
create table #topstates
(state nvarchar(255),
topstate float
)
insert into #topstates
select state,round(avg(literacy),0)as avg_literacy_ratio from Project1..Data1 group by State order by avg_literacy_ratio desc;

select * from #topstates order by #topstates.topstate desc;
select top 3 * from #topstates order by #topstates.topstate desc;



drop table if exists #bottomstates;
create table #bottomstates
(state nvarchar(255),
bottomstate float
)
insert into #bottomstates
select state,round(avg(literacy),0)as avg_literacy_ratio from Project1..Data1 group by State order by avg_literacy_ratio desc;

select * from #bottomstates order by #bottomstates.bottomstate asc;
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc;

--11.. Combine two tables(union operator)
select * from(
select top 3 * from #topstates order by #topstates.topstate desc)a
union
select * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc)b;


--12.. Find the States details starting with letter a

select * from Project1..Data1 where State like 'a%'

--13..Find the States details ending with letter h

select * from Project1.dbo.Data1 where State like '%h'

--14.. Find the Common record between two tables (joining two tables by inner join)

 select * from Data1
 inner join Data2 on Data1.State=Data2.State

select a.district,a.state,a.sex_ratio,b.population from Project1..Data1 a inner join Project1..Data2 b on a.District=b.District 

--15..Rank states by literacy rate (Window function)
select state,round(avg(literacy),2)as literacy_rate,rank() over(order by avg(literacy)desc)as literacy_rank from project1..Data1 group by state;

--16..Top 3 Districts from each state(Partition by)
select* from(select state,district,literacy,rank()over(partition by state order by literacy desc) as rank_in_state from Project1..Data1)t
where rank_in_state<=3;

--17.. Running Total Population(Cumulative sum)
select state,district,Population,sum(population) over (order by state) as runnning_population from Project1..Data2;

--18.. Find districts having literacy above state average(correlated subquery)
select district,state,literacy from Project1..Data1 d1 where literacy > (select avg(literacy)from Project1..Data1 d2 where d1.State=d2.State);

--19.. Create literacy category using CASE
select district,state,literacy,case
when literacy >=90 then 'Excellent'
when literacy >=75 then 'Good'
when literacy >=60 then 'Average'else 'Poor'
end as literacy_category
from Project1..Data1

--20..Find top populaion district in each state
select* from (select a.state,a.district,b.population,RANK() OVER(PARTITION BY a.state ORDER BY b.population DESC) AS rnk
FROM  Project1..Data1 a
JOIN Project1..Data2 b
On a.District = b.District)t where rnk =1;

--21..Percentage contribution of each state in total population
select state,sum(population) as state_population,sum(population)*100.0/(select sum(population) from Project1..Data2) as percentage_share from Project1..Data2
group by state order by percentage_share desc;

--22.. Find duplicate districts( Data cleaning )
select district,count(*)from Project1..Data1 group by District having count(*)>1;

--23.. CTE
with state_population as (select state,sum(population) as total_population from Project1..Data2 group by state)
select*,rank()over(order by total_population desc) as Population_rank from state_population;

--24..Find states above average population
with state_population as (select state,sum(population) as total_population from Project1..Data2 group by state) 
select* from state_population where total_population>(select avg(total_population) from state_population);

--25.. NTILE function 
select state,sum(population) as total_population,ntile(4)over(order by sum(population)desc) as population_group from Project1..Data2
group by State;

--26..Create View
create view state_population_view as select state,sum(population) as total_population from Project1..Data2
group by state;

select* from state_population_view;

select*

