package com.example.scg;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

// Minimal Spring Boot entry point. With spring-cloud-starter-gateway on the
// classpath the gateway and its actuator endpoint are auto-configured; no routes
// are predefined, so the attacker supplies one via the actuator API.
@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
