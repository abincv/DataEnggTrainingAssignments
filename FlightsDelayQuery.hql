use hivedb;

--c.

describe parquet_flightsdelay;
select * from parquet_flightsdelay limit 10;


--d.

select avg(arrival_delay) as AVG_ARR_DELAY
from parquet_flightsdelay;

--e) Days of months with respected to average of arrival delays

select day,avg(departure_delay+arrival_delay) as avg_delay
from parquet_flightsdelay
group by DAY
order by day;

--f) Arrange weekdays with respect to the average arrival delays caused

select DAY_of_week,avg(departure_delay+arrival_delay) as avg_delay
from parquet_flightsdelay
group by DAY_of_week
order by DAY_of_week;

--g) Arrange Days of month as per cancellations done in Descending

select day,count(*) as no_of_cancellations
from parquet_flightsdelay
where cancelled=1
group by day
order by day;

--h) Finding busiest airports with respect to day of week

select day_of_week,airport,flights_count
from (
select DAY_of_week,airport,count(airport) as flights_count,max(count(airport)) over(partition by DAY_of_week) as max_busy
from (select DAY_of_week,destination_airport as airport
from parquet_flightsdelay
union all
select DAY_of_week,origin_airport
from parquet_flightsdelay) as ap
group by DAY_of_week,airport
) as tmp
where flights_count=max_busy;


--i) Finding airlines that make the maximum number of cancellations

select airline,count(*) as no_of_cancellations
from parquet_flightsdelay
where cancelled=1
group by airline
order by no_of_cancellations desc;

--j) Find and order airlines in descending that make the most number of diversions

select airline,count(*) as no_of_diversions
from parquet_flightsdelay
where diverted=1
group by airline
order by no_of_diversions desc;

--k) Finding days of month that see the most number of diversion

select day,count(*) as no_of_diversions
from parquet_flightsdelay
where diverted=1
group by day
order by no_of_diversions desc;



--l) Calculating mean and standard deviation of departure delay for all flights in minutes

select avg(DEPARTURE_DELAY),stddev(DEPARTURE_DELAY)
from parquet_flightsdelay;

--m) Calculating mean and standard deviation of arrival delay for all flights in minutes

select avg(ARRIVAL_DELAY),stddev(ARRIVAL_DELAY)
from parquet_flightsdelay;


--n) Create a partitioning table “flights_partition” using partitioned by schema “CANCELLED”  ..........

set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;

create table if not exists flights_partition(
ID int, YEAR int, MONTH int, DAY int, DAY_OF_WEEK int,
AIRLINE varchar(10), FLIGHT_NUMBER int, TAIL_NUMBER varchar(10),
ORIGIN_AIRPORT varchar(5), DESTINATION_AIRPORT varchar(5),
SCHEDULED_DEPARTURE int, DEPARTURE_TIME int, DEPARTURE_DELAY int,
TAXI_OUT int,WHEELS_OFF int,SCHEDULED_TIME int,ELAPSED_TIME int,
AIR_TIME int, DISTANCE int, WHEELS_ON int, TAXI_IN int,
SCHEDULED_ARRIVAL int, ARRIVAL_TIME int ,ARRIVAL_DELAY int,
DIVERTED int,CANCELLATION_REASON string,
AIR_SYSTEM_DELAY int, SECURITY_DELAY int, AIRLINE_DELAY int,
LATE_AIRCRAFT_DELAY int, WEATHER_DELAY int)
partitioned by (CANCELLED int)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
stored as textfile;

--insert overwrite table flights_partition
--partition(CANCELLED)
--select * from flightsdelay where id<1000;



-- the above query is wrong because the partitioned column should be the last column of source table....correct answer is down


DROP table if exists flights_data;

CREATE EXTERNAL TABLE IF NOT EXISTS flights_data(ID int, YEAR int, MONTH INT,
DAY INT, DAY_OF_WEEK INT,AIRLINE VARCHAR(20),FLIGHT_NUMBER INT, TAIL_NUMBER VARCHAR(30),
ORIGIN_AIRPORT VARCHAR(20), DESTINATION_AIRPORT VARCHAR(20), SCHEDULED_DEPARTURE INT,
DEPARTURE_TIME INT,DEPARTURE_DELAY INT, TAXI_OUT INT, WHEELS_OFF INT,SCHEDULED_TIME INT,
ELAPSED_TIME INT, AIR_TIME INT,DISTANCE INT, WHEELS_ON INT, TAXI_IN INT, SCHEDULED_ARRIVAL INT,
ARRIVAL_TIME INT, ARRIVAL_DELAY INT,DIVERTED INT, CANCELLED INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION '/hive_flights';

set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;

CREATE EXTERNAL TABLE IF NOT EXISTS flights_part(ID int, YEAR int, MONTH INT,
DAY INT, DAY_OF_WEEK INT, AIRLINE VARCHAR(20),FLIGHT_NUMBER INT, TAIL_NUMBER VARCHAR(30),
ORIGIN_AIRPORT VARCHAR(20), DESTINATION_AIRPORT VARCHAR(20), SCHEDULED_DEPARTURE INT,
DEPARTURE_TIME INT,DEPARTURE_DELAY INT, TAXI_OUT INT, WHEELS_OFF INT,SCHEDULED_TIME INT,
ELAPSED_TIME INT, AIR_TIME INT,DISTANCE INT, WHEELS_ON INT, TAXI_IN INT, SCHEDULED_ARRIVAL INT,
ARRIVAL_TIME INT, ARRIVAL_DELAY INT,DIVERTED INT)
partitioned by (CANCELLED INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

insert overwrite table flights_part
partition(CANCELLED)
select * from flights_data;

select * from flights_part limit 5;




--o) Create Bucketing table “Flights_Bucket” using clustered by MONTH into 3 Buckets Note: No partitioning, only bucketing of table.

set hive.enforce.bucketing=true;

create table if not exists Flights_Bucket(
ID int, YEAR int, MONTH int, DAY int, DAY_OF_WEEK int,
AIRLINE varchar(10), FLIGHT_NUMBER int, TAIL_NUMBER varchar(10),
ORIGIN_AIRPORT varchar(5), DESTINATION_AIRPORT varchar(5),
SCHEDULED_DEPARTURE int, DEPARTURE_TIME int, DEPARTURE_DELAY int,
TAXI_OUT int,WHEELS_OFF int,SCHEDULED_TIME int,ELAPSED_TIME int,
AIR_TIME int, DISTANCE int, WHEELS_ON int, TAXI_IN int,
SCHEDULED_ARRIVAL int, ARRIVAL_TIME int ,ARRIVAL_DELAY int,
DIVERTED int,CANCELLED int,CANCELLATION_REASON string,
AIR_SYSTEM_DELAY int, SECURITY_DELAY int, AIRLINE_DELAY int,
LATE_AIRCRAFT_DELAY int, WEATHER_DELAY int)
clustered by (month) into 3 buckets 
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
stored as textfile;

--insert overwrite table Flights_Bucket
--select * from flightsdelay;


--p) Get count of data of each bucket.
select count(*) from Flights_Bucket TABLESAMPLE(BUCKET 1 out of 3);
select count(*) from Flights_Bucket TABLESAMPLE(BUCKET 2 out of 3);
select count(*) from Flights_Bucket TABLESAMPLE(BUCKET 3 out of 3);


--q) Finding all diverted Route from a source to destination Airport &amp; which route is the most diverted

select origin_airport,destination_airport,count(*) as Divert_Count
from parquet_flightsdelay
where diverted=1
group by origin_airport,destination_airport
order by Divert_count desc;

--r) -- 12.Finding AIRLINES with its total flight count, total number of flights arrival delayed by more than 30 Minutes, % of such flights delayed by more than 30 minutes when it is not Weekends with minimum count of flights from Airlines by more than 10. Also Exclude some of Airlines 'AK', 'HI', 'PR', 'VI' and arrange output in descending order by % of such count of flights.

select airline,total_flights,arr_delay_gt_30,ARR_Delay_gt_30_not_weekend,  ARR_Delay_gt_30_not_weekend*100/total_flights as percentage
from (select airline,count(airline) as total_flights, 
sum(case when ARRIVAL_DELAY > 30 then 1 else 0 end) as ARR_Delay_gt_30, 
sum(case when ARRIVAL_DELAY > 30 and (day_of_week <> 6 and day_of_week <> 7 ) then 1 else 0 end) as ARR_Delay_gt_30_not_weekend
from parquet_flightsdelay
where airline not in ('AK', 'HI', 'PR', 'VI') 
group by airline
having total_flights>10) as temp
order by percentage desc;




--s) Finding AIRLINES with its total flight count with total number of flights departure delayed by less than 30 Minutes, % of such flights delayed by less than 30 minutes when it is Weekends with minimum count of flights from Airlines by more than 10. Also Exclude some of Airlines 'AK', 'HI', 'PR', 'VI' and arrange output in descending order by % of such count of flights.

select airline,total_flights,dep_delay_lt_30,dep_Delay_lt_30_is_weekend,  dep_Delay_lt_30_is_weekend*100/total_flights as percentage
from (select airline,count(airline) as total_flights, 
sum(case when DEPARTURE_DELAY < 30 then 1 else 0 end) as dep_Delay_lt_30, 
sum(case when DEPARTURE_DELAY < 30 and (day_of_week = 6 or day_of_week = 7 ) then 1 else 0 end) as dep_Delay_lt_30_is_weekend
from parquet_flightsdelay
where airline not in ('AK', 'HI', 'PR', 'VI') 
group by airline
having total_flights>10) as temp
order by percentage desc;


--t) When is the best time of day/day of week/time of a year to fly with minimum delays?

select DAY_of_week,avg(departure_delay+arrival_delay+AIR_SYSTEM_DELAY+SECURITY_DELAY+AIRLINE_DELAY+LATE_AIRCRAFT_DELAY+WEATHER_DELAY) as delay
from parquet_flightsdelay
group by DAY_of_week
order by delay ;
