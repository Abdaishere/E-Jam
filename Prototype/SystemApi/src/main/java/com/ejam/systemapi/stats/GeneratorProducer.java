package com.ejam.systemapi.stats;

import com.ejam.systemapi.stats.SchemaRegistry.Generator;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;


public class GeneratorProducer {
    static KafkaProducer<String, Generator> producer;

    public static Generator rebuildFromString(String string) {
        String[] values = string.split(String.valueOf(' '));

        return Generator.newBuilder()
                .setMacAddress(values[0])
                .setStreamId(values[1])
                .setPacketsSent(Long.parseLong(values[2]))
                .setPacketsErrors(Long.parseLong(values[3]))
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
