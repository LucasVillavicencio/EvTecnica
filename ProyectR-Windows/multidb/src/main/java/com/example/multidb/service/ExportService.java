package com.example.multidb.service;

import com.example.multidb.db1.entity.Empleado;
import com.example.multidb.db1.repository.EmpleadoRepository;
import com.example.multidb.db2.entity.Departamento;
import com.example.multidb.db2.repository.DepartamentoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.List;
@Service
public class ExportService {

    private final EmpleadoRepository empleadoRepository;
    private final DepartamentoRepository departamentoRepository;

    @Autowired
    public ExportService(EmpleadoRepository empleadoRepository,
                         DepartamentoRepository departamentoRepository) {
        this.empleadoRepository = empleadoRepository;
        this.departamentoRepository = departamentoRepository;
    }

    public void exportarDatos(String horaActual) {
        // Se obtienen todos los empleados y departamentos desde la base de datos
        List<Empleado> empleados = empleadoRepository.findAll();
        List<Departamento> departamentos = departamentoRepository.findAll();

        // Se define el nombre del archivo a generar con la hora como sufijo
        File archivo = new File("Reporte_" + horaActual + ".txt");

        try (BufferedWriter writer = new BufferedWriter(
                new OutputStreamWriter(new FileOutputStream(archivo), StandardCharsets.UTF_8))) {

            // Se agrega el BOM para que sea reconocido correctamente
            writer.write('\uFEFF');

            // Se escribe la sección de empleados
            writer.write("Empleados:\n");
            for (Empleado e : empleados) {
                writer.write(String.format("%d - %s - %s\n", e.getId(), e.getNombre(), e.getCargo()));
            }

            // Se separa con una línea y se escribe la sección de departamentos
            writer.write("\nDepartamentos:\n");
            for (Departamento d : departamentos) {
                writer.write(String.format("%d - %s\n", d.getId(), d.getNombre()));
            }

            System.out.println("Archivo generado correctamente: " + archivo.getAbsolutePath());

        } catch (IOException e) {
            // Se imprime el error en caso de fallar la escritura
            System.err.println("Error al escribir el archivo: " + e.getMessage());
        }
    }
}
