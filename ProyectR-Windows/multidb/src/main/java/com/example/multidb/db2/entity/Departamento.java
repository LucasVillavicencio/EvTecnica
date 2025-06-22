package com.example.multidb.db2.entity;

import jakarta.persistence.*;
@Entity
@Table(name = "Departamentos")
public class Departamento {

    @Id
    private Integer id;

    @Column(length = 100)
    private String nombre;

    //Constructores
    public Departamento(){}

    public Departamento(Integer id, String nombre){
        this.id = id;
        this.nombre = nombre;
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
}
