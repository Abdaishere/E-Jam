package com.ejam.systemapi;

import com.ejam.systemapi.stats.KafkaInitializer;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SystemApiApplication {
    public static void main(String[] args) {
        KafkaInitializer.Init(true);
        SpringApplication.run(SystemApiApplication.class, args);
    }
}
