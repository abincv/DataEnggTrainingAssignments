use hivedb;

drop table if exists HREmployee;
drop table if exists parquet_HREmployee;

CREATE EXTERNAL TABLE IF NOT EXISTS HREmployee (EmployeeID INT,Department string,JobRole varchar(30),Attrition varchar(10),Gender varchar(10),Age INT,MaritalStatus varchar(20),Education varchar(50),EducationField varchar(50),BusinessTravel varchar(50),JobInvolvement varchar(20),JobLevel int,JobSatisfaction varchar(30),Hourlyrate int,Income int,Salaryhike int,OverTime varchar(110),Workex int,YearsSinceLastPromotion int,EmpSatisfaction varchar(30),TrainingTimesLastYear int,WorkLifeBalance varchar(30),Performance_Rating varchar(30))
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION '/HREmployee'
tblproperties("skip.header.line.count" = "1");



CREATE EXTERNAL TABLE IF NOT EXISTS parquet_HREmployee (EmployeeID INT,Department string,JobRole varchar(30),Attrition varchar(10),Gender varchar(10),Age INT,MaritalStatus varchar(20),Education varchar(50),EducationField varchar(50),BusinessTravel varchar(50),JobInvolvement varchar(20),JobLevel int,JobSatisfaction varchar(30),Hourlyrate int,Income int,Salaryhike int,OverTime varchar(110),Workex int,YearsSinceLastPromotion int,EmpSatisfaction varchar(30),TrainingTimesLastYear int,WorkLifeBalance varchar(30),Performance_Rating varchar(30))
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS parquetfile;


insert into table parquet_HREmployee
SELECT * FROM HREmployee;



