package com.ejam.systemapi.stats.SchemaRegistry.statistics;

import java.util.UUID;

import com.ejam.systemapi.stats.SchemaRegistry.Generator;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;


import com.github.javafaker.Faker;



public class GeneratorProducer implements Runnable {
    static KafkaProducer<String, Generator> producer;
   
    @Override
    public void run() {
        ProduceFakeData();
    }

    public static void ProduceFakeData() {
        Faker faker = new Faker();
        // send fake data with Kafka producer each 1 second to the topic is the same as the name of the class
        
        while (true) {
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            
            // create a fake Generator object
            Generator generator = Generator.newBuilder()
                    .setMacAddress(faker.internet().macAddress())
                    .setStreamId(UUID.randomUUID().toString().substring(0, 3))
                    .setPacketsSent(faker.number().randomNumber())
                    .setPacketsErrors(faker.number().randomNumber())
                    .setTimestamp(faker.date().birthday().toInstant())
                    .build();
            
            // send the fake data to the topic and print the exception if there is any
            producer.send(new ProducerRecord<>(generator.getClass().getSimpleName(), generator), (metadata, exception) -> {
                if (exception != null) {
                    exception.printStackTrace();
                }
            });
        }
    }
}
