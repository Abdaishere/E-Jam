package com.ejam.systemapi.stats;

import com.ejam.systemapi.GlobalVariables;
import io.confluent.kafka.serializers.KafkaAvroSerializer;
import io.confluent.kafka.serializers.KafkaAvroSerializerConfig;
import io.confluent.kafka.serializers.subject.TopicRecordNameStrategy;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;
import java.util.UUID;

public class KafkaInitializer {
    static GlobalVariables globalVariables = GlobalVariables.getInstance();
    public static String BOOTSTRAP_SERVERS;
    public final static String CLIENT_ID_CONFIG = UUID.randomUUID().toString();
    public static String SCHEMA_REGISTRY_URL;

    public static Properties prop = new Properties();
    public static KafkaProducer<String, Object> producer;

    /**
     * Get the bootstrap servers from the admin config
     * you can change the admin address in the admin config file, or you can change it here.
     */
    public static void GetBootstrapServers() {
        // TODO: uncomment this line when you want to use the admin config
//        globalVariables.readAdminConfig();

//        BOOTSTRAP_SERVERS = String.format("http://%s:9092", globalVariables.ADMIN_ADDRESS);
//        SCHEMA_REGISTRY_URL = String.format("http://%s:8081", globalVariables.ADMIN_ADDRESS);

        BOOTSTRAP_SERVERS = String.format("http://%s:9092", "localhost");
        SCHEMA_REGISTRY_URL = String.format("http://%s:8081", "localhost");


        System.out.println("Client ID: " + CLIENT_ID_CONFIG);
        System.out.println("this is the bootstrap server: " + BOOTSTRAP_SERVERS);
        System.out.println("this is the schema registry url: " + SCHEMA_REGISTRY_URL);
    }

    /**
     * Create the properties for the producer
     * This is where you can change the producer properties
     * For more information about the producer properties, check this link:
     * <a href="https://kafka.apache.org/documentation/#producerconfigs">producer configs</a>
     */
    public static void CreateProperties() {
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

    }

    /**
     * Initialize the Kafka producer and the stats manager
     *
     * @param isRunnable true to run the stats manager in a thread
     *                   false to run the generator and verifier in threads
     */
    public static void Init(boolean isRunnable) {
        // Get the bootstrap servers from the admin config
        GetBootstrapServers();

        // Create the properties for the producer
        CreateProperties();

        // Create the producer
        producer = new KafkaProducer<>(prop);

        // Set the producer for the GeneratorProducer and VerifierProducer
        GeneratorProducer.producer = producer;
        VerifierProducer.producer = producer;

        // true to run the stats manager in a thread
        // false to run the generator and verifier in threads
        if (isRunnable) {
            Thread statsManagerThread = new Thread(StatsManager.getInstance());
            statsManagerThread.start();
        } else {
            // ( ͡° ͜ʖ ͡°)
            Thread generatorThread = new Thread(new GeneratorProducer());
            generatorThread.start();

            Thread verifierThread = new Thread(new VerifierProducer());
            verifierThread.start();
        }
    }

    /**
     * Main method to run the KafkaInitializer
     * This is where you can run the KafkaInitializer without running the whole application
     */
    public static void main(String[] args) {
        Init(true);
    }
}
