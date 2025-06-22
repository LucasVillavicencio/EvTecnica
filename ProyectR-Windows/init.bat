@echo off
setlocal

REM Ruta al archivo que contiene las funciones (sin barra extra al final)
set "PATH_FUNC=%~dp0utils\Setup_BD.bat"

REM Crear las bases de datos
call "%PATH_FUNC%" INIT_SERVER

echo Esperando que SQL Server este listo...
timeout /t 20

call "%PATH_FUNC%" INIT_BD BaseDatosUno
call "%PATH_FUNC%" INIT_BD BaseDatosDos

REM Crear tablas en cada base de datos

REM BaseDatosUno -> Tabla Empleados
call "%PATH_FUNC%" INIT_TABLES Empleados BaseDatosUno
call "%PATH_FUNC%" ADD_COLUMNS_CHAR Empleados BaseDatosUno Nombre
call "%PATH_FUNC%" ADD_COLUMNS_CHAR Empleados BaseDatosUno Cargo

REM BaseDatosDos -> Tabla Departamentos
call "%PATH_FUNC%" INIT_TABLES Departamentos BaseDatosDos
call "%PATH_FUNC%" ADD_COLUMNS_CHAR Departamentos BaseDatosDos Nombre

REM Insertar datos de prueba

REM Tabla Empleados (BaseDatosUno)
call "%PATH_FUNC%" INSERT_TO_TABLE_THREEARG Empleados BaseDatosUno "" 1 Juan Gerente
call "%PATH_FUNC%" INSERT_TO_TABLE_THREEARG Empleados BaseDatosUno "" 2 Maria Analista
call "%PATH_FUNC%" INSERT_TO_TABLE_THREEARG Empleados BaseDatosUno "" 3 Pedro Desarrollador

REM Tabla Departamentos (BaseDatosDos)
call "%PATH_FUNC%" INSERT_TO_TABLE_TWOARG Departamentos BaseDatosDos "" 1 Finanzas
call "%PATH_FUNC%" INSERT_TO_TABLE_TWOARG Departamentos BaseDatosDos "" 2 RRHH
call "%PATH_FUNC%" INSERT_TO_TABLE_TWOARG Departamentos BaseDatosDos "" 3 Gerencia


REM --- Ahora verificar datos guardados ---

echo Consultando datos en BaseDatosUno - Empleados:
docker exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P Test#12345 -d BaseDatosUno -Q "SELECT * FROM Empleados;" -C

echo.
echo Consultando datos en BaseDatosDos - Departamentos:
docker exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P Test#12345 -d BaseDatosDos -Q "SELECT * FROM Departamentos;" -C

pause

java -jar multidb-0.0.1-SNAPSHOT.jar

pause