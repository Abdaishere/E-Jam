package com.ejam.kafka.producer;

import com.ejam.avro.statistics.statisticsValue;
import com.github.javafaker.Faker;
import io.confluent.kafka.serializers.KafkaAvroSerializer;
import io.confluent.kafka.serializers.KafkaAvroSerializerConfig;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.time.LocalDateTime;
import java.util.Objects;
import java.util.Properties;
import java.util.Scanner;
import java.util.UUID;

public class StatisticsProducer {
    InetAddress localHost = InetAddress.getLocalHost();
    NetworkInterface ni = NetworkInterface.getByInetAddress(localHost);
    final String MAC_ADDRESS = ni.getHardwareAddress().toString();
    final static Logger logger = LoggerFactory.getLogger(StatisticsProducer.class);
    final String topic;
    final KafkaProducer<String, statisticsValue> producer;

    final String STAT_DIR = "/etc/EJam/stats";

    public StatisticsProducer(String bootstrapServers, String topic, String clientId, String schemaRegistry) throws SocketException, UnknownHostException {
        logger.info("Initializing Producer");
        this.topic = topic;
        var props = new Properties();
        props.put(ProducerConfig.CLIENT_ID_CONFIG, clientId);
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, KafkaAvroSerializer.class);
        props.put(KafkaAvroSerializerConfig.SCHEMA_REGISTRY_URL_CONFIG, schemaRegistry);
        props.put(ProducerConfig.LINGER_MS_CONFIG, 500);

        producer = new KafkaProducer<>(props);
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            logger.info("Shutting down producer");
            producer.close();
        }));
    }

    public void produce() throws Exception {
//        var faker = new Faker();
        while (true) {

            File folder = new File(STAT_DIR);
            File[] listOfFiles = folder.listFiles();

            for (File file : listOfFiles) {
                if (file.isFile()) {
                    String[] name = file.getName().split("_");
                    Scanner myReader = new Scanner(file);
                    Integer receivedCount = myReader.nextInt();
                    Integer errorCount = myReader.nextInt();
                    var staticsData = statisticsValue.newBuilder()
                            .setId(UUID.randomUUID().toString())
                            .setSource(MAC_ADDRESS + file.getName())
                            .setErrorTotal(errorCount)
                            .setRate(receivedCount)
                            .setTotal(receivedCount + errorCount)
                            .setDate(LocalDateTime.now())
                            .setVerifier(Objects.equals(name[0], "Ver"))
                            .build();
                    var record = new ProducerRecord<String, statisticsValue>(topic, staticsData.getSource().toString(), staticsData);

                    producer.send(record, ((metadata, exception) -> logger.info("Produced record {} to topic {} partition {} at offset {}",
                            file.getName(), metadata.topic(), metadata.partition(), metadata.offset())));

                    file.delete();
                }
            }
            Thread.sleep(1000);
        }
    }
}