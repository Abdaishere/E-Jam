package com.ejam.systemapi.stats;

import com.ejam.systemapi.GlobalVariables;
import com.ejam.systemapi.InstanceControl.UTILs;
import com.ejam.systemapi.stats.SchemaRegistry.Generator;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import com.ejam.systemapi.stats.SchemaRegistry.Verifier;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;


public class VerifierProducer {
    static KafkaProducer<String, Verifier> producer;

    public static Verifier rebuildFromString(String string) {
        GlobalVariables globalVariables = GlobalVariables.getInstance();
        String[] values = string.split(String.valueOf(' '));

        LocalDate localDate = LocalDate.now();

        // Get the default time zone
        ZoneId zoneId = ZoneId.systemDefault();

        // Convert the local date to an instant
        Instant instant = localDate.atStartOfDay(zoneId).toInstant();

        return Verifier.newBuilder()
                .setMacAddress(UTILs.convertToColonFormat(UTILs.getMyMacAddress(globalVariables.GATEWAY_INTERFACE)))
                .setStreamId(values[1])
                .setPacketsCorrect(Long.parseLong(values[2]))
                .setPacketsErrors(Long.parseLong(values[3]))
                .setPacketsDropped(Long.parseLong(values[4]))
                .setPacketsOutOfOrder(Long.parseLong(values[5]))
                .setTimestamp(instant)
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
