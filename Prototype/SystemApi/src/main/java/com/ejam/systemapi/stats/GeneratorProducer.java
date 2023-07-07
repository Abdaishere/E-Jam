package com.ejam.systemapi.stats;

import com.ejam.systemapi.GlobalVariables;
import com.ejam.systemapi.InstanceControl.UTILs;
import com.ejam.systemapi.stats.SchemaRegistry.Generator;
import com.github.javafaker.Faker;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;

import java.time.Instant;
import java.util.UUID;


public class GeneratorProducer implements Runnable {
    static KafkaProducer<String, Object> producer;

    public static Generator rebuildFromParams(String macAdd, String streamID, Long pacSent, Long pacErr) {

        return Generator.newBuilder()
                .setMacAddress(macAdd)
                .setStreamId(streamID)
                .setPacketsSent(pacSent)
                .setPacketsErrors(pacErr)
                .setTimestamp(Instant.now())
                .build();
    }

    public static Generator rebuildFromString(String string) {
        GlobalVariables globalVariables = GlobalVariables.getInstance();
        String[] values = string.split(String.valueOf(' '));
        String macAdd = UTILs.convertToColonFormat(UTILs.getMyMacAddress(globalVariables.GATEWAY_INTERFACE)).toUpperCase();

        return rebuildFromParams(macAdd, values[1], Long.parseLong(values[2]), Long.parseLong(values[3]));
    }

    public static void produceDataToKafkaBroker(Generator generator) {
        System.out.println("Sending data to Kafka broker ...");
        producer.send(new ProducerRecord<>(generator.getClass().getSimpleName(), generator), (metadata, exception) -> {
            if (exception != null) {
                exception.printStackTrace();
            } else {
                System.out.println("Data sent successfully");
            }
        });
    }

    @Override
    public void run() {
        ProduceFakeData();
    }

    public static void ProduceFakeData() {
        Faker faker = new Faker();
        // send fake data with Kafka producer each 1 second to the topic is the same as the name of the class

        while (true) {
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            // create a fake Generator object
            Generator generator = Generator.newBuilder()
                    .setMacAddress(faker.internet().macAddress())
                    .setStreamId(UUID.randomUUID().toString().substring(0, 3))
                    .setPacketsSent(faker.number().randomNumber())
                    .setPacketsErrors((faker.number().randomNumber() + 1) / 5)
                    .setTimestamp(Instant.now()).build();

            // send the fake data to the topic and print the exception if there is any
            producer.send(new ProducerRecord<>(generator.getClass().getSimpleName(), generator), (metadata, exception) -> {
                if (exception != null) {
                    exception.printStackTrace();
                } else {
                    System.out.println("Sent successfully!");
                }
            });
        }
    }
}
