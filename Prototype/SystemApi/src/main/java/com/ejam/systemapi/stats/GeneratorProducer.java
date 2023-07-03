package com.ejam.systemapi.stats;

import com.ejam.systemapi.GlobalVariables;
import com.ejam.systemapi.InstanceControl.UTILs;
import com.ejam.systemapi.stats.SchemaRegistry.Generator;
import com.github.javafaker.Faker;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.UUID;


public class GeneratorProducer {
    static KafkaProducer<String, Generator> producer;

    public static Generator rebuildFromParams(String macAdd, String streamID, Long pacSent, Long pacErr) {
        LocalDate localDate = LocalDate.now();
        // Get the default time zone
        ZoneId zoneId = ZoneId.systemDefault();
        // Convert the local date to an instant
        Instant instant = localDate.atStartOfDay(zoneId).toInstant();
//        System.out.println(UTILs.convertToColonFormat(UTILs.getMyMacAddress(globalVariables.GATEWAY_INTERFACE)).toUpperCase());
        return Generator.newBuilder()
                .setMacAddress(macAdd)
                .setStreamId(streamID)
                .setPacketsSent(pacSent)
                .setPacketsErrors(pacErr)
                .setTimestamp(instant)
                .build();
    }
    public static Generator rebuildFromString(String string) {
        GlobalVariables globalVariables = GlobalVariables.getInstance();
        String[] values = string.split(String.valueOf(' '));
        String macAdd = UTILs.convertToColonFormat(UTILs.getMyMacAddress(globalVariables.GATEWAY_INTERFACE)).toUpperCase();
       return rebuildFromParams(macAdd,values[1],Long.parseLong(values[2]),Long.parseLong(values[3]));
    }

    public static void produceDataToKafkaBroker(Generator generator) {
        System.out.println(generator);
        System.out.println(producer);
        Faker faker = new Faker();
        generator = Generator.newBuilder()
                .setMacAddress(generator.getMacAddress())
                .setStreamId(generator.getStreamId())
                .setPacketsSent(faker.number().randomNumber())
                .setPacketsErrors(faker.number().randomNumber())
                .setTimestamp(faker.date().birthday().toInstant())
                .build();
        producer.send(new ProducerRecord<>(generator.getClass().getSimpleName(), generator), (metadata, exception) -> {
            System.out.println("Trying to send...");
            System.out.println(metadata.toString());
            if (exception != null) {
                exception.printStackTrace();
            }
        });
        System.out.println("produceDataToKafkaBroker is executed!");
    }
}
