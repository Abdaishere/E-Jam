package com.ejam.systemapi.stats;

import io.confluent.kafka.serializers.KafkaAvroSerializer;
import io.confluent.kafka.serializers.KafkaAvroSerializerConfig;
import io.confluent.kafka.serializers.subject.TopicRecordNameStrategy;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;

public class KafkaInitializer {
    public final static String BOOTSTRAP_SERVERS = "http://192.168.1.30:9092";
    public final static String CLIENT_ID_CONFIG = "client1";
    public final static String SCHEMA_REGISTRY_URL = "http://192.168.1.30:8081";


    public static void Init() {
        Properties prop = new Properties();
        prop.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, KafkaInitializer.BOOTSTRAP_SERVERS);
        prop.put(ProducerConfig.CLIENT_ID_CONFIG, KafkaInitializer.CLIENT_ID_CONFIG);
        prop.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        prop.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, KafkaAvroSerializer.class);
        prop.put(KafkaAvroSerializerConfig.SCHEMA_REGISTRY_URL_CONFIG, KafkaInitializer.SCHEMA_REGISTRY_URL);
        prop.put(KafkaAvroSerializerConfig.AUTO_REGISTER_SCHEMAS, true);
        prop.put(KafkaAvroSerializerConfig.VALUE_SUBJECT_NAME_STRATEGY, TopicRecordNameStrategy.class);
        prop.put(KafkaAvroSerializerConfig.KEY_SUBJECT_NAME_STRATEGY, TopicRecordNameStrategy.class);
        prop.put(ProducerConfig.LINGER_MS_CONFIG, 500);
        prop.put(ProducerConfig.BATCH_SIZE_CONFIG, 16384);

        GeneratorProducer.producer = new KafkaProducer<>(prop);
        VerifierProducer.producer = new KafkaProducer<>(prop);

        Thread statsManagerThread = new Thread(StatsManager.getInstance());
        statsManagerThread.start();
    }

    public static void main(String[] args) {
        Init();
    }
}
