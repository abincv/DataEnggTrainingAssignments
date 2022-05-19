use hivedb;

drop table if exists FlightsDelay;
drop table if exists parquet_FlightsDelay;

--a.

create table if not exists flightsdelay(
ID int, YEAR int, MONTH int, DAY int, DAY_OF_WEEK int,
AIRLINE varchar(10), FLIGHT_NUMBER int, TAIL_NUMBER varchar(10),
ORIGIN_AIRPORT varchar(5), DESTINATION_AIRPORT varchar(5),
SCHEDULED_DEPARTURE int, DEPARTURE_TIME int, DEPARTURE_DELAY int,
TAXI_OUT int,WHEELS_OFF int,SCHEDULED_TIME int,ELAPSED_TIME int,
AIR_TIME int, DISTANCE int, WHEELS_ON int, TAXI_IN int,
SCHEDULED_ARRIVAL int, ARRIVAL_TIME int ,ARRIVAL_DELAY int,
DIVERTED int, CANCELLED int,CANCELLATION_REASON string,
AIR_SYSTEM_DELAY int, SECURITY_DELAY int, AIRLINE_DELAY int,
LATE_AIRCRAFT_DELAY int, WEATHER_DELAY int)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION '/FlightsDelay'
tblproperties("skip.header.line.count" = "1");


--b.


create table if not exists parquet_flightsdelay(
ID int, YEAR int, MONTH int, DAY int, DAY_OF_WEEK int,
AIRLINE varchar(10), FLIGHT_NUMBER int, TAIL_NUMBER varchar(10),
ORIGIN_AIRPORT varchar(5), DESTINATION_AIRPORT varchar(5),
SCHEDULED_DEPARTURE int, DEPARTURE_TIME int, DEPARTURE_DELAY int,
TAXI_OUT int,WHEELS_OFF int,SCHEDULED_TIME int,ELAPSED_TIME int,
AIR_TIME int, DISTANCE int, WHEELS_ON int, TAXI_IN int,
SCHEDULED_ARRIVAL int, ARRIVAL_TIME int ,ARRIVAL_DELAY int,
DIVERTED int, CANCELLED int,CANCELLATION_REASON string,
AIR_SYSTEM_DELAY int, SECURITY_DELAY int, AIRLINE_DELAY int,
LATE_AIRCRAFT_DELAY int, WEATHER_DELAY int)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS parquetfile;

insert into table parquet_flightsdelay
SELECT * FROM flightsdelay;
