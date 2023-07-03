package com.ejam.systemapi;

import com.ejam.systemapi.stats.KafkaInitializer;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SystemApiApplication {
    public static void main(String[] args) {
        SpringApplication.run(SystemApiApplication.class, args);
        KafkaInitializer.Init(true);
    }
}
