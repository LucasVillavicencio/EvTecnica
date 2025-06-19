package com.example.multidb.service;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Component
public class ScheduledExportService {

    private final ExportService exportService;

    public ScheduledExportService(ExportService exportService){
        this.exportService = exportService;
    }

    @Scheduled(cron = "0 * * * * *")
    public void ejecutarExportacionProgramada(){
        String horaActual = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        System.out.println("Exportacion ejecutada en el dia y hora:" + horaActual);
        exportService.exportarDatos(horaActual);
    }
}


