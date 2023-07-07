package com.ejam.systemapi.stats;

import com.ejam.systemapi.GlobalVariables;
import com.ejam.systemapi.InstanceControl.UTILs;
import com.ejam.systemapi.stats.SchemaRegistry.Generator;
import com.ejam.systemapi.stats.SchemaRegistry.Verifier;
import com.github.javafaker.Faker;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;

import java.time.Instant;
import java.util.UUID;


public class VerifierProducer implements Runnable {
    static KafkaProducer<String, Object> producer;

    public static Verifier rebuildFromParams(String macAdd, String streamID, Long pacCorrect, Long pacErr,
                                             Long pacDropped, Long packOutOfOrder) {

        return Verifier.newBuilder()
                .setMacAddress(macAdd)
                .setStreamId(streamID)
                .setPacketsCorrect(pacCorrect)
                .setPacketsErrors(pacErr)
                .setPacketsDropped(pacDropped)
                .setPacketsOutOfOrder(packOutOfOrder)
                .setTimestamp(Instant.now())
                .build();
    }
    public static Verifier rebuildFromString(String string) {
        GlobalVariables globalVariables = GlobalVariables.getInstance();
        String[] values = string.split(String.valueOf(' '));

        return rebuildFromParams(
                UTILs.convertToColonFormat(UTILs.getMyMacAddress(globalVariables.GATEWAY_INTERFACE))
                ,values[1]
                ,Long.parseLong(values[2])
                ,Long.parseLong(values[3])
                ,Long.parseLong(values[4])
                ,Long.parseLong(values[5]));
    }

    public static void produceDataToKafkaBroker(Verifier verifier) {
        System.out.println("Sending data to Kafka broker ...");
        producer.send(new ProducerRecord<>(verifier.getClass().getSimpleName(), verifier), (metadata, exception) -> {
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

        // send fake data with Kafka producer each 1 second to the topic is the same as
        // the name of the class
        while (true) {
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            // create a fake Verifier object
            Verifier verifier = Verifier.newBuilder()
                    .setMacAddress(faker.internet().macAddress())
                    .setStreamId(UUID.randomUUID().toString().substring(0, 3))
                    .setPacketsCorrect((faker.number().randomNumber() + 1) / 5)
                    .setPacketsErrors((faker.number().randomNumber() + 1) / 5)
                    .setPacketsDropped((faker.number().randomNumber() + 1) / 7)
                    .setPacketsOutOfOrder(faker.number().randomNumber())
                    .setTimestamp(Instant.now())
                    .build();

            // send the fake data to the topic and print the exception if there is any
            producer.send(new ProducerRecord<>(verifier.getClass().getSimpleName(), verifier), (metadata, exception) -> {
                if (exception != null) {
                    exception.printStackTrace();
                } else {
                    System.out.println("Data sent successfully");
                }
            });
        }
    }
}
