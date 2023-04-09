package com.example.systemapi.stats;

import io.confluent.kafka.serializers.KafkaAvroSerializer;
import io.confluent.kafka.serializers.KafkaAvroSerializerConfig;
import io.confluent.kafka.serializers.subject.TopicRecordNameStrategy;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;
import com.example.systemapi.stats.SchemaRegistry.Generator;
import com.example.systemapi.stats.SchemaRegistry.Verifier;

import java.util.Properties;

public class KafkaInitializer {
    public final static String BOOTSTRAP_SERVERS = "http://localhost:9092";
    public final static String CLIENT_ID_CONFIG = "client1";
    public final static String SCHEMA_REGISTRY_URL = "http://localhost:8081";

    public static void Init() {
        Properties prop = new Properties();
        prop.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, KafkaInitializer.BOOTSTRAP_SERVERS);
        prop.put(ProducerConfig.CLIENT_ID_CONFIG, KafkaInitializer.CLIENT_ID_CONFIG);
        prop.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        prop.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        prop.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, KafkaAvroSerializer.class);
        prop.put(KafkaAvroSerializerConfig.SCHEMA_REGISTRY_URL_CONFIG, KafkaInitializer.SCHEMA_REGISTRY_URL);
        prop.put(KafkaAvroSerializerConfig.AUTO_REGISTER_SCHEMAS, true);
        prop.put(KafkaAvroSerializerConfig.VALUE_SUBJECT_NAME_STRATEGY, TopicRecordNameStrategy.class);
        prop.put(KafkaAvroSerializerConfig.KEY_SUBJECT_NAME_STRATEGY, TopicRecordNameStrategy.class);
        prop.put(ProducerConfig.LINGER_MS_CONFIG, 500);
        prop.put(ProducerConfig.BATCH_SIZE_CONFIG, 16384);

        KafkaProducer<String, Generator> generatorProducer = new KafkaProducer<>(prop);
        GeneratorProducer.producer = generatorProducer;

        KafkaProducer<String, Verifier> verifierProducer = new KafkaProducer<>(prop);
        VerifierProducer.producer = verifierProducer;

        Thread generatorThread = new Thread(new GeneratorProducer());
        generatorThread.start();

        Thread verifierThread = new Thread(new VerifierProducer());
        verifierThread.start();
    }

    public static void main(String[] args) {
        Init();
    }

}
