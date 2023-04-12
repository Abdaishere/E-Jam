package com.ejam.systemapi.stats;

import com.ejam.systemapi.stats.SchemaRegistry.Generator;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import com.ejam.systemapi.stats.SchemaRegistry.Verifier;


public class VerifierProducer {
    static KafkaProducer<String, Verifier> producer;

    public static Verifier rebuildFromString(String string) {
        String[] values = string.split(String.valueOf(' '));

        return Verifier.newBuilder()
                .setMacAddress(values[0])
                .setStreamId(values[1])
                .setPacketsCorrect(Long.parseLong(values[2]))
                .setPacketsErrors(Long.parseLong(values[3]))
                .setPacketsDropped(Long.parseLong(values[4]))
                .setPacketsOutOfOrder(Long.parseLong(values[5]))
                .build();
    }

    public static void produceDataToKafkaBroker(Verifier verifier) {
        producer.send(new ProducerRecord<>(verifier.getClass().getSimpleName(), verifier), (metadata, exception) -> {
            if (exception != null) {
                exception.printStackTrace();
            }
        });
    }
}
