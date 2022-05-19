// Databricks notebook source


// COMMAND ----------

import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._

// COMMAND ----------

// dbfs:/FileStore/shared_uploads/214435@ust-global.com/Weblog.csv

SparkSession.builder().appName("WebLog").master("local[*]").getOrCreate()


// COMMAND ----------

val logs_DF_withheader = spark.read.text("dbfs:/FileStore/shared_uploads/214435@ust-global.com/Weblog.csv")

// COMMAND ----------

val header=logs_DF_withheader.first()
val logs_DF = logs_DF_withheader.filter(row => row != header)

// COMMAND ----------

logs_DF.show(5,false)

// COMMAND ----------

//logs_DF.select(regexp_extract($"value","""^(\d+.\d+.\d+.\d+),\[(\d{2}\/\w{3}\/\d{4}:\d{2}:\d{2}:\d{2}),(\w{3,})\s(\/.*)\s(HTTP\/[\d.]+),(\d{3,})$""",6).alias("host")).show()
//logs_DF.select(regexp_extract($"value", """\[(\d{2}/\w{3}/\d{4}:\d{2}:\d{2}:\d{2})""",1).alias("Timestamp")).show()
//logs_DF.select(regexp_extract($"value", """(.*),\[(.*),(.*)\s(.*)\s(.*),(.*)""", 6).alias("Method")).show(false)

// COMMAND ----------

// MAGIC %md
// MAGIC #### a.Parsing the Log Files using RegExp & Pre-process Raw Log Data into Data frame with attributes. 

// COMMAND ----------

var weblog_df = logs_DF.select(regexp_extract($"value", """^(\d+.\d+.\d+.\d+),\[(\d{2}\/\w{3}\/\d{4}:\d{2}:\d{2}:\d{2}),(\w{3,})\s(\/.*)\s(HTTP\/[\d.]+),(\d{3,})$""", 1).alias("Host"),
                                             regexp_extract($"value", """^(\d+.\d+.\d+.\d+),\[(\d{2}\/\w{3}\/\d{4}:\d{2}:\d{2}:\d{2}),(\w{3,})\s(\/.*)\s(HTTP\/[\d.]+),(\d{3,})$""", 2).alias("Timestamp"),
                                             regexp_extract($"value", """^(\d+.\d+.\d+.\d+),\[(\d{2}\/\w{3}\/\d{4}:\d{2}:\d{2}:\d{2}),(\w{3,})\s(\/.*)\s(HTTP\/[\d.]+),(\d{3,})$""", 3).alias("Method"),
                                             regexp_extract($"value", """^(\d+.\d+.\d+.\d+),\[(\d{2}\/\w{3}\/\d{4}:\d{2}:\d{2}:\d{2}),(\w{3,})\s(\/.*)\s(HTTP\/[\d.]+),(\d{3,})$""", 4).alias("URL"),
                                             regexp_extract($"value", """^(\d+.\d+.\d+.\d+),\[(\d{2}\/\w{3}\/\d{4}:\d{2}:\d{2}:\d{2}),(\w{3,})\s(\/.*)\s(HTTP\/[\d.]+),(\d{3,})$""", 5).alias("Protocol"),
                                             regexp_extract($"value", """^(\d+.\d+.\d+.\d+),\[(\d{2}\/\w{3}\/\d{4}:\d{2}:\d{2}:\d{2}),(\w{3,})\s(\/.*)\s(HTTP\/[\d.]+),(\d{3,})$""", 6).cast("int").alias("Status"))
weblog_df.show()

// COMMAND ----------

// MAGIC %md
// MAGIC ####b.Use data cleaning: count null and remove null values. Fix rows with null status (Drop those rows).

// COMMAND ----------



// Find Count of Null, None, NaN of all dataframe columns
import org.apache.spark.sql.functions.{col,when,count}
import org.apache.spark.sql.Column

// UDF
def countNullCols (columns:Array[String]):Array[Column] = {
   columns.map(c => {
   count(when(col(c).isNull, c)).alias(c)
  })
}

weblog_df.select(countNullCols(weblog_df.columns): _*).show()



// COMMAND ----------

// filtering unwanted and null rows

//weblog_df = weblog_df.filter(!($"host" === "" || $"timestamp" === "" || $"method" === "" || $"url" === "" || $"protocol" === "" || $"status" === ""))
//weblog_df.show()
weblog_df=weblog_df.na.drop(Seq("Status"))

weblog_df.count()

// COMMAND ----------

// MAGIC %md
// MAGIC ####c.Pre-process and fix timestamp month name to month value. Convert Datetime (timestamp column) as Days, Month & Year.

// COMMAND ----------



val month_map = Map("Jan" -> 1, "Feb" -> 2, "Mar" -> 3, "Apr" -> 4, "May" -> 5, "Jun" -> 6, "Jul" -> 7, "Aug" -> 8, "Sep" -> 9,
                   "Oct" -> 10, "Nov" -> 11, "Dec" -> 12)
// UDF 
def parse_time(s : String):String = {
  "%3$s-%2$s-%1$s %4$s:%5$s:%6$s".format(s.substring(0,2), month_map(s.substring(3,6)), s.substring(7,11), s.substring(12,14), s.substring(15,17), s.substring(18))
}

val toTimestamp = udf[String, String](parse_time(_))

weblog_df = weblog_df.select($"*", to_timestamp(toTimestamp($"Timestamp")).alias("time_stamp")).drop("Timestamp")

weblog_df.show





// COMMAND ----------


weblog_df = weblog_df.withColumn("day",dayofmonth($"time_stamp")).withColumn("month",month($"time_stamp")).withColumn("year",year($"time_stamp"))
weblog_df.show

// COMMAND ----------

// MAGIC %md
// MAGIC ####d.Create new parquet file using cleaned Data Frame. Read the parquet file. 

// COMMAND ----------


// Convert Textfile Format to Parquet File Format
weblog_df.write.parquet("dbfs:/FileStore/shared_uploads/214435@ust-global.com/Assignment_finalsssssl/")


// Read Parquet File Format
val parquetlogsDF = spark.read.parquet("dbfs:/FileStore/shared_uploads/214435@ust-global.com/Assignment_finalsssssl/")
parquetlogsDF.show()

// COMMAND ----------

// MAGIC %md
// MAGIC ####e.Show the summary of each column

// COMMAND ----------


parquetlogsDF.summary().show()


// COMMAND ----------

// MAGIC %md
// MAGIC ####f.Display frequency of 200 status code in the response for each month.

// COMMAND ----------


parquetlogsDF.filter($"Status" === 200).groupBy("month").count().sort("month").show(false)


// COMMAND ----------

// MAGIC %md
// MAGIC ####g.Frequency of Host Visits in November Month

// COMMAND ----------


parquetlogsDF.filter($"month" === 11).groupBy("host").count().sort(desc("count")).show


// COMMAND ----------

// MAGIC %md
// MAGIC ####h.Display Top 15 Error Paths - status != 200.

// COMMAND ----------


parquetlogsDF.filter($"Status" =!= 200).groupBy("URL").count().sort(desc("count")).show(15,false)


// COMMAND ----------

// MAGIC %md
// MAGIC ####i.Display Top 10 Paths with Error - with status equals 200.

// COMMAND ----------


parquetlogsDF.filter($"Status" === 200).groupBy("URL").count().sort(desc("count")).show(10,false)


// COMMAND ----------

// MAGIC %md
// MAGIC ####j.Exploring 404 status code. Listing 404 status Code Records. List Top 20 Host with 404 response status code (Query + Visualization).

// COMMAND ----------

parquetlogsDF.createOrReplaceTempView("logsTable")


// COMMAND ----------

// MAGIC %sql
// MAGIC select host, count(host) as 404_error_count 
// MAGIC from logsTable
// MAGIC where status=404 
// MAGIC group by host 
// MAGIC order by 404_error_count desc
// MAGIC limit 20

// COMMAND ----------

// MAGIC %md
// MAGIC ####k.Display the List of 404 Error Response Status Code per Day (Query + Visualization)

// COMMAND ----------

// MAGIC %sql
// MAGIC select day, count(day) as 404_error_count 
// MAGIC from logsTable
// MAGIC where status=404 
// MAGIC group by day 
// MAGIC order by day 

// COMMAND ----------

// MAGIC %md
// MAGIC ####l.List Top 20 Paths (Endpoint) with 404 Response Status Code.

// COMMAND ----------

// MAGIC 
// MAGIC 
// MAGIC %sql
// MAGIC select url, count(url) as 404_error_count 
// MAGIC from logsTable
// MAGIC where status=404 
// MAGIC group by url 
// MAGIC order by 404_error_count desc 
// MAGIC limit 20
// MAGIC 
// MAGIC --//spark.sql("select url, count(url) as 404_error_count  from logsTable where status=404  group by url  order by 404_error_count desc limit 20").show()

// COMMAND ----------

// MAGIC %md
// MAGIC ####m.Query to Display Distinct Path responding 404 in status error.

// COMMAND ----------

spark.sql("select distinct(url) as url_404_error  from logsTable where status=404 ").show(false)

// COMMAND ----------

// MAGIC %md
// MAGIC ####n.Find the number of unique source IPs that have made requests to the webserver for each month.

// COMMAND ----------

// MAGIC %sql
// MAGIC select host,count(host) as months_active
// MAGIC from (select month,host from logsTable group by month,host) 
// MAGIC group by host
// MAGIC --having count(host)=12
// MAGIC 
// MAGIC 
// MAGIC --spark.sql("select distinct(host) from logsTable where host in (select month,host from logsTable group by month,host)").show(false)

// COMMAND ----------

// MAGIC %md
// MAGIC ####o.Display the top 20 requested Paths in each Month (Query + Visualization)

// COMMAND ----------

// MAGIC %sql
// MAGIC select * from(select * ,row_number() over (partition by month order by cnt desc) as rank
// MAGIC               from (select month,url, count(url) as cnt
// MAGIC                     from logsTable 
// MAGIC                     group by month,url 
// MAGIC                     ) tmp
// MAGIC               ) ranked
// MAGIC where rank <=20
// MAGIC       

// COMMAND ----------

// MAGIC %md
// MAGIC ####p.Query to Display Distinct Path responding 404 in status error.

// COMMAND ----------

spark.sql("select distinct(url) as url_404_error  from logsTable where status=404 ").show(false)

// COMMAND ----------



// COMMAND ----------


