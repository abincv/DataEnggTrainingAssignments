
import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.spark.SparkConf

// Import Kafka & Spark Streaming Packages
import org.apache.spark.streaming.kafka010.{ConsumerStrategies, KafkaUtils, LocationStrategies}
import org.apache.spark.streaming.{Durations, StreamingContext}

import scala.collection.mutable

object KafkaStreaming4 {

def main(argv: Array[String]):Unit = {

        //Configure Spark to connect to Kafka Running on Local Machine
        val kafkaParam = new mutable.HashMap[String, String]()
        kafkaParam.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092")
        kafkaParam.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer")
        kafkaParam.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer")

        // Consumer Group ID
        kafkaParam.put(ConsumerConfig.GROUP_ID_CONFIG, "group1")
        kafkaParam.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "latest")
        kafkaParam.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "true")

        val conf = new SparkConf().setMaster("local[4]").setAppName("KafkaStreaming")

        // Read stream messages in batches of 1 min Intervals
        val sparkStreamingContext = new StreamingContext(conf, Durations.seconds(60))

        // Config Spark to Listen messages from Kafka in Topic List
        val topicList = List("kafka_abin")

        // Read value of each message from Kafka
        val messageStream = KafkaUtils.createDirectStream(sparkStreamingContext,
                                LocationStrategies.PreferConsistent,
                                ConsumerStrategies.Subscribe[String, String](topicList, kafkaParam))
                                
        val product_Category = messageStream.map((record) =>(record.value));

        val categoryOrderStream = product_Category.map((record)=>(record.toString.split(",")(1),record.toString.split(",")(5).toInt)).reduceByKey((i1,i2)=>i1+i2);

	//sort by true is ascending order.....
        val topN = categoryOrderStream.transform((rdd) =>{rdd.sortBy(_._2,false)});
        topN.print(10);
	
	//val total= product_Category.map((record)=>("total units",record.toString.split(",")(5).toInt)).reduceByKey((i1,i2)=>i1+i2);
	//total.print();

        sparkStreamingContext.start()
        sparkStreamingContext.awaitTermination()


    }
}

