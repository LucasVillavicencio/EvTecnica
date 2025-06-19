package com.example.multidb.db1.entity;
import jakarta.persistence.*;

@Entity
@Table(name = "Empleados")
public class Empleado {

    @Id
    private Integer id;

    @Column(length = 100)
    private String nombre;

    @Column(length = 100)
    private String cargo;

    //Constructores
    public Empleado(){}

    public Empleado(Integer id, String nombre, String cargo){
        this.id = id;
        this.nombre = nombre;
        this.cargo = cargo;
    }

    //getters y setters

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getCargo() {
        return cargo;
    }

    public void setCargo(String cargo) {
        this.cargo = cargo;
    }
}
