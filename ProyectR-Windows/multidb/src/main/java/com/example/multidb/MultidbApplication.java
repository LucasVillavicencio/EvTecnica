package com.example.multidb;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@EnableScheduling
@SpringBootApplication
public class MultidbApplication {

	public static void main(String[] args) {
		System.setProperty("java.awt.headless", "false");SpringApplication.run(MultidbApplication.class, args);
	}
}
