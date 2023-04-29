package com.ejam.systemapi;

import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class SystemApiApplication {
    public static void main(String[] args) {
        SpringApplication.run(SystemApiApplication.class, args);
    }
}
