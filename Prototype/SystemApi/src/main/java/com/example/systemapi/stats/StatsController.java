package com.example.systemapi.stats;

import org.springframework.kafka.core.KafkaTemplate;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;

public class StatsController {
    private static KafkaTemplate<String, byte[]> kafkaTemplate;

    public StatsController(KafkaTemplate<String, byte[]> kafkaTemplate) {
        StatsController.kafkaTemplate = kafkaTemplate;
    }

    public static void publishToGenerators(GeneratorStatsContainer stats) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        ObjectOutputStream objectOutputStream = new ObjectOutputStream(byteArrayOutputStream);
        objectOutputStream.writeObject(stats);
        objectOutputStream.flush();
        byte[] serializedStats = byteArrayOutputStream.toByteArray();

        kafkaTemplate.send("generators", serializedStats);
    }

    public static void publishToVerifiers(VerifierStatsContainer stats) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        ObjectOutputStream objectOutputStream = new ObjectOutputStream(byteArrayOutputStream);
        objectOutputStream.writeObject(stats);
        objectOutputStream.flush();
        byte[] serializedStats = byteArrayOutputStream.toByteArray();

        kafkaTemplate.send("verifiers", serializedStats);
    }
}
