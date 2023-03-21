package com.example.systemapi.InstanceControl.stats;

import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;

@Configuration
public class KafkaTopicConfig {
    @Bean
    public NewTopic generatorsTopic() {
        return TopicBuilder.name("generators").build();
    }

    @Bean
    public NewTopic verifiersTopic() {
        return TopicBuilder.name("verifiers").build();
    }
}
