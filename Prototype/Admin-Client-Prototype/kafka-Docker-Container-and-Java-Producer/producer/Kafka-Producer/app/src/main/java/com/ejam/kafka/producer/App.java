package com.ejam.kafka.producer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class App {
    static final Logger logger = LoggerFactory.getLogger(App.class);

    public static void main(String[] args) {
        logger.info("Starting Kafka Avro Client Application");

        String action = "actual_producer";
        try {
            switch (action) {
                case "actual_producer":
                    runProducer();
                    break;
                case "fake_producer":
                    // used for debugging
                    break;
                default:
                    logger.error("Unknown action {}", action);
                    break;
            }
        } catch (Exception e) {
            logger.error("Error in main app", e);
        }
    }

    static void runProducer() throws Exception {
        var producer = new StatisticsProducer(
                "localhost:9092",
                "statistics",
                "statistics_value_0",
                "http://localhost:8081"
        );
        producer.produce();
    }
}
