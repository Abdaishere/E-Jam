package com.ejam.systemapi.stats;

import com.ejam.systemapi.stats.SchemaRegistry.Generator;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;


public class GeneratorProducer {
    static KafkaProducer<String, Generator> producer;

    public static Generator rebuildFromString(String string) {
        String[] values = string.split(String.valueOf(' '));

        LocalDate localDate = LocalDate.now();

        // Get the default time zone
        ZoneId zoneId = ZoneId.systemDefault();

        // Convert the local date to an instant
        Instant instant = localDate.atStartOfDay(zoneId).toInstant();

        return Generator.newBuilder()
                .setMacAddress(values[0])
                .setStreamId(values[1])
                .setPacketsSent(Long.parseLong(values[2]))
                .setPacketsErrors(Long.parseLong(values[3]))
                .setTimestamp(instant)
                .build();
    }

    public static void produceDataToKafkaBroker(Generator generator) {
        System.out.println(generator);
        producer.send(new ProducerRecord<>(generator.getClass().getSimpleName(), generator), (metadata, exception) -> {
            if (exception != null) {
                exception.printStackTrace();
            }
        });
    }
}
