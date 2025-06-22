# EvTecnica

# ProyectoR - Instalación y Ejecución VERSION WINDOWS

## Requisitos previos

- Tener instalado **WSL (Windows Subsystem for Linux)**.  
  En caso de no tenerlo, abre PowerShell y ejecuta:

  ```powershell
  wsl --install

- Recordar **reiniciar el equipo** una vez finalizada la instalación de WSL.

## En caso de fallo habilitar permisos de virtualizacion a traves de la bios o powershell

- Para powershell usando los siguientes comandos
  ```powershell
  bcdedit /set hypervisorlaunchtype auto
  dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
  dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

- Reiniciar y proceder a reinstalar

  ```powershell
  wsl --set-default-version 2
  wsl --install -d Ubuntu
  
- Instalar **Docker Desktop** para Windows.  
Asegúrate de que Docker esté corriendo correctamente antes de continuar.

---

### Requisito: Java instalado

Este proyecto requiere tener **Java instalado** para poder ejecutar el archivo `.jar` que genera reportes automáticamente cada minuto.

Si no tienes Java instalado, puedes descargar una versión gratuita y open-source desde Adoptium:

[👉 https://adoptium.net/](https://adoptium.net/es/temurin/releases/?variant=openjdk17&jvmVariant=hotspot&os=any&arch=any&version=17)

Se recomienda instalar la versión **Temurin 17 o superior**.


Pasos:

1. Descarga el instalador adecuado para tu sistema operativo.
2. Durante la instalación, selecciona la opción que agrega Java al `PATH`.
3. Verifica que Java esté correctamente instalado ejecutando en la terminal o PowerShell:
   
    ```powershell
    java -version

## Instrucciones de ejecución

1. Ejecutar el archivo `init.bat` **con permisos de administrador**.

2. El script `init.bat` realizará toda la configuración necesaria y, al finalizar, ejecutará el archivo `.jar`.

3. El `.jar` generará reportes en formato `.txt` cada minuto, ubicados en la carpeta correspondiente del proyecto.

---

## Notas

- Asegúrate que Docker Desktop esté funcionando correctamente antes de ejecutar el script.




-------------------------------------------------------------------

# Instrucciones para ejecutar el código VERSION KALI LINUX

Este código está pensado para un ambiente de trabajo en un sistema operativo **Kali Linux limpio recién instalado**.  
Se recomienda probarlo en este entorno para que se ejecute automáticamente sin problemas, ya que de otro modo podrían requerirse configuraciones manuales adicionales.

---

## Paso 1: Ejecutar el script `installBD.sh`

Primero, debes dar permisos de ejecución al script e iniciarlo:

```bash
chmod +x InstallBD.sh
./InstallBD.sh
```

Este script instalará automáticamente las siguientes herramientas y configuraciones:

- `jq` (procesador JSON)
- `curl` (herramienta para transferir datos)
- `unzip` (para descomprimir archivos)
- `openjdk-17` (Java Development Kit versión 17)
- `maven` (herramienta para gestión y construcción de proyectos Java)
- `git` (control de versiones)
- `docker` (contenedores)
- IDE **IntelliJ IDEA**

En caso de que alguna instalación falle, se recomienda instalar manualmente el componente correspondiente.

Además, el script configurará y probará la base de datos **SQL Server** ejecutándose dentro de un contenedor Docker.

Al final del proceso, el script te pedirá reiniciar el equipo. Luego de reiniciar, vuelve a ejecutar:

```bash
./InstallBD.sh
```

para completar la configuración.

En caso de haber problemas con las llaves de acceso a el sqlserver, volver a correr el installBD.sh

---

## Paso 2: Verificar que SQL Server esté funcionando en Docker

Para confirmar que el servidor SQL Server esté corriendo correctamente, usa el siguiente comando:

```bash
docker ps
```

- Si ves el contenedor llamado `sqlserver` en ejecución, está funcionando correctamente.
- En caso de error por permisos, intenta reiniciar el equipo.
- Si el servidor está apagado, puedes iniciarlo manualmente con:

```bash
docker start sqlserver
```

---

## Paso 3: Abrir y ejecutar el programa

1. Abre la carpeta `multidb` con **IntelliJ IDEA**.

2. IntelliJ puede solicitarte instalar dependencias; acepta para asegurar el correcto funcionamiento.

3. Ejecuta la clase principal `MultidbApplication` ubicada en:

```
/src/main/java/com/example/multidb
```

Esto generará un reporte en la carpeta `multidb` (que es padre de `src`) cada un minuto.

---

## Paso 4: Configurar la frecuencia de ejecución

La generación del reporte se controla mediante una expresión **cron** en el archivo:

```
scheduledExportService.java
```

### Explicación del formato cron usado

En Spring Boot, el cron es una cadena de texto con 6 o 7 campos, que representan:

```
segundos minutos horas díaDelMes mes díaDeLaSemana [año (opcional)]
```

| Campo         | Rango permitido   | Descripción                         |
|---------------|-------------------|-----------------------------------|
| segundos      | 0-59              | Segundo en el minuto               |
| minutos       | 0-59              | Minuto en la hora                 |
| horas         | 0-23              | Hora del día                      |
| día del mes   | 1-31              | Día del mes                       |
| mes           | 1-12 o JAN-DEC    | Mes del año                      |
| día de la semana | 0-7 o SUN-SAT   | Día de la semana (0 y 7 son domingo) |
| año (opcional) | 1970-2099         | Año                             |

---

### Caracteres especiales frecuentes

- `*` → cualquier valor válido para ese campo.
- `?` → ningún valor especificado (solo para día del mes o día de la semana).
- `,` → lista de valores (ejemplo: `MON,WED,FRI`).
- `-` → rango de valores (ejemplo: `10-12` horas).
- `/` → paso o incremento (ejemplo: `0/15` en minutos significa cada 15 minutos).
- `L` → último día del mes o semana.
- `W` → día laboral más cercano.
- `#` → por ejemplo, `2#1` significa el primer lunes del mes.

---

### Ejemplos comunes

| Cron                              | Descripción                                  |
|----------------------------------|----------------------------------------------|
| `0 0 10 * * ?`                   | Ejecuta a las 10:00:00 AM todos los días     |
| `0 0/5 * * * ?`                  | Ejecuta cada 5 minutos                        |
| `0 50 10 ? * THU`                | Ejecuta cada jueves a las 10:50 AM            |
| `0 0 9-17 * * MON-FRI`           | Ejecuta a cada hora de 9 a 17, lunes a viernes|
| `0 0 12 1 1 ?`                   | Ejecuta al mediodía del 1 de enero            |

---

### Para modificar la hora y día en tu proyecto

Busca en `scheduledExportService.java` la anotación:

```java
@Scheduled(cron = "tu expresión cron aquí")
```

y reemplaza `"tu expresión cron aquí"` por la expresión que necesites. Por ejemplo, para ejecutar el jueves a las 10:50 AM:

```java
@Scheduled(cron = "0 50 10 ? * THU")
```

---

## Notas finales

- Para cualquier problema con permisos o configuraciones, intenta reiniciar tu equipo.
- Asegúrate de que el contenedor Docker de SQL Server esté corriendo antes de ejecutar el programa.
- Si deseas modificar la carpeta donde se guardan los reportes o el nombre, puedes cambiar el código en `scheduledExportService.java`.

---

Si tienes dudas o necesitas ayuda con algún paso, no dudes en consultarme.
