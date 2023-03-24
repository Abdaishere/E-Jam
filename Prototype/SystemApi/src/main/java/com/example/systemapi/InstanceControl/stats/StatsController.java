package com.example.systemapi.InstanceControl.stats;

import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;

public class StatsController {
    private final KafkaTemplate<String, byte[]> kafkaTemplate;

    public StatsController(KafkaTemplate<String, byte[]> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void publishToGenerators(GeneratorStats stats) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        ObjectOutputStream objectOutputStream = new ObjectOutputStream(byteArrayOutputStream);
        objectOutputStream.writeObject(stats);
        objectOutputStream.flush();
        byte[] serializedStats = byteArrayOutputStream.toByteArray();

        kafkaTemplate.send("generators", serializedStats);
    }

    public void publishToVerifiers(VerifierStats stats) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        ObjectOutputStream objectOutputStream = new ObjectOutputStream(byteArrayOutputStream);
        objectOutputStream.writeObject(stats);
        objectOutputStream.flush();
        byte[] serializedStats = byteArrayOutputStream.toByteArray();

        kafkaTemplate.send("verifiers", serializedStats);
    }
}
