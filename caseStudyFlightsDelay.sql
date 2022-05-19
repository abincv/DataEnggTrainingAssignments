create database flightdb;
use flightdb;

drop table flightsdelay;

-- 1.Create a Table Flights with schemas of Table

create table if not exists flightsdelay(
ID int, YEAR int, MONTH int, DAY int, DAY_OF_WEEK int,
AIRLINE varchar(10), FLIGHT_NUMBER int, TAIL_NUMBER varchar(10),
ORIGIN_AIRPORT varchar(5), DESTINATION_AIRPORT varchar(5),
SCHEDULED_DEPARTURE int, DEPARTURE_TIME int, DEPARTURE_DELAY int,
TAXI_OUT int,WHEELS_OFF int,SCHEDULED_TIME int,ELAPSED_TIME int,
AIR_TIME int, DISTANCE int, WHEELS_ON int, TAXI_IN int,
SCHEDULED_ARRIVAL int, ARRIVAL_TIME int ,ARRIVAL_DELAY int,
DIVERTED int, CANCELLED int,CANCELLATION_REASON text,
AIR_SYSTEM_DELAY int, SECURITY_DELAY int, AIRLINE_DELAY int,
LATE_AIRCRAFT_DELAY int, WEATHER_DELAY int);


-- 2.Insert all records into flights table. Use dataset Flights_Delay.csv

LOAD DATA LOCAL INFILE 'D:/Important/UST/Training/Assignment/Flights_Delay.csv' INTO 
TABLE flightsdelay FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;


select * from flightsdelay;

-- 3.Average Arrival delay caused by airlines

select avg(arrival_delay) as AVG_ARR_DELAY
from flightsdelay;


-- 4.Display the Day of Month with AVG Delay [Hint: Add Count() of Arrival & Departure Delay]
select day,avg(departure_delay+arrival_delay) as avg_delay
from flightsdelay
group by DAY
order by day;


-- 5.Analysis for each month with total number of cancellations.

select month,count(*) as no_of_cancellations
from flightsdelay
where cancelled=1
group by month
order by month;

-- 6.Find the airlines that make maximum number of cancellations
select airline,count(*) as no_of_cancellations
from flightsdelay
where cancelled=1
group by airline
order by no_of_cancellations desc;

-- 7. Finding the Busiest Airport [Hint: Find Count() of origin airport and destination airport]
select airport,count(airport) as flight_counts
from (select destination_airport as airport
	from flightsdelay
	union all
	select origin_airport
	from flightsdelay) as ap
group by airport
order by flight_counts desc;


-- 8.Find the airlines that make maximum number of Diversions [Hint: Diverted = 1 indicate Diversion]alter
select airline,count(*) as no_of_diversions
from flightsdelay
where diverted=1
group by airline
order by no_of_diversions desc;


-- 9.Finding all diverted Route from a source to destination Airport & which route is the most diverted route.

select origin_airport,destination_airport,count(*) as Divert_Count
from flightsdelay
where diverted=1
group by origin_airport,destination_airport
order by Divert_count desc;

-- select count(*)
-- from flightsdelay
-- where origin_airport='ord' and destination_airport='ase' and diverted=1;

-- 10.Finding all Route from origin to destination Airport & which route got delayed.

select origin_airport,destination_airport,sum(case when departure_delay+arrival_delay > 0 then 1 else 0 end) as delay_count
from flightsdelay
group by  origin_airport,destination_airport
having delay_count > 0 ;



-- 11.Finding the Route which Got Delayed the Most [Hint: Route include Origin Airport and Destination Airport, Group By Both ]
select origin_airport,destination_airport,sum(case when departure_delay+arrival_delay > 0 then 1 else 0 end) as delay_count
from flightsdelay
group by  origin_airport,destination_airport
order by delay_count desc;

-- 12.Finding AIRLINES with its total flight count, total number of flights arrival delayed by more than 30 Minutes, % of such flights delayed by more than 30 minutes when it is not Weekends with minimum count of flights from Airlines by more than 10. Also Exclude some of Airlines 'AK', 'HI', 'PR', 'VI' and arrange output in descending order by % of such count of flights.

select airline,total_flights,arr_delay_gt_30,ARR_Delay_gt_30_not_weekend,  ARR_Delay_gt_30_not_weekend*100/total_flights as percentage
from (select airline,count(airline) as total_flights, 
			 sum(case when ARRIVAL_DELAY > 30 then 1 else 0 end) as ARR_Delay_gt_30, 
			 sum(case when ARRIVAL_DELAY > 30 and (day_of_week <> 6 and day_of_week <> 7 ) then 1 else 0 end) as ARR_Delay_gt_30_not_weekend
	  from flightsdelay
      where airline not in ('AK', 'HI', 'PR', 'VI') 
      group by airline
      having total_flights>10) as temp
order by percentage desc;




