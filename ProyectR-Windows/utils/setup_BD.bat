@echo off
setlocal

set CONT_NAME=sqlserver
set SA_PASSWORD=Test#12345
set SQLCMD_PATH=/opt/mssql-tools18/bin/sqlcmd

if "%~1"=="INIT_SERVER" goto :INIT_SERVER
if "%~1"=="INIT_BD" goto :INIT_BD
if "%~1"=="INIT_TABLES" goto :INIT_TABLES
if "%~1"=="ADD_COLUMNS_CHAR" goto :ADD_COLUMNS_CHAR
if "%~1"=="INSERT_TO_TABLE_THREEARG" goto :INSERT_TO_TABLE_THREEARG
if "%~1"=="INSERT_TO_TABLE_TWOARG" goto :INSERT_TO_TABLE_TWOARG

echo [ERROR] Funcion desconocida: %~1
goto :eof

REM ----------------------------------------------------
REM Inicio del proceso de instalacion de sqlserver en docker
:INIT_SERVER
	docker pull mcr.microsoft.com/mssql/server:2019-latest
	docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=%SA_PASSWORD%" -p 1433:1433 --name %CONT_NAME% -d mcr.microsoft.com/mssql/server:2019-latest
	goto :eof

REM ----------------------------------------------------
REM Creacion de base de datos
:INIT_BD
	set "DB_NOMBRE=%~2"
	docker exec %CONT_NAME% %SQLCMD_PATH% -S localhost -U SA -P %SA_PASSWORD% -b -Q "IF DB_ID(N'%DB_NOMBRE%') IS NULL CREATE DATABASE %DB_NOMBRE%;" -C
	if errorlevel 1 (
		echo [ERROR] Fallo la creacion de %DB_NOMBRE%.
		pause
		exit /b 1
	)
	goto :eof

REM ----------------------------------------------------
REM Creacion de tabla si no existe
:INIT_TABLES
	set "TB_NOMBRE=%~2"
	set "DB_NOMBRE=%~3"
	docker exec %CONT_NAME% %SQLCMD_PATH% -S localhost -U SA -P %SA_PASSWORD% -b -d %DB_NOMBRE% -Q "IF OBJECT_ID(N'%TB_NOMBRE%','U') IS NULL BEGIN CREATE TABLE %TB_NOMBRE%(Id INT PRIMARY KEY); END" -C
	if errorlevel 1 (
		echo [ERROR] Fallo la creacion de la tabla %TB_NOMBRE% en la base %DB_NOMBRE%.
		pause
		exit /b 1
	)
	goto :eof

REM ----------------------------------------------------
REM Agrega columna tipo NVARCHAR(100)
:ADD_COLUMNS_CHAR
	set "TB_NOMBRE=%~2"
	set "DB_NOMBRE=%~3"
	set "COLUMN=%~4"
	docker exec %CONT_NAME% %SQLCMD_PATH% -S localhost -U SA -P %SA_PASSWORD% -b -d %DB_NOMBRE% -Q "ALTER TABLE %TB_NOMBRE% ADD %COLUMN% NVARCHAR(100);" -C
	if errorlevel 1 (
		echo [ERROR] Fallo agregar columna %COLUMN% a la tabla %TB_NOMBRE% en la base %DB_NOMBRE%.
		pause
		exit /b 1
	)
	goto :eof

REM ----------------------------------------------------
REM Inserta registro con 3 columnas (Id, Nombre, Cargo)
:INSERT_TO_TABLE_THREEARG
	set "TB_NOMBRE=%~2"
	set "DB_NOMBRE=%~3"
	set "ID=%~5"
	set "NAME=%~6"
	set "JOB=%~7"
	docker exec %CONT_NAME% %SQLCMD_PATH% -S localhost -U SA -P %SA_PASSWORD% -b -d %DB_NOMBRE% -Q "INSERT INTO %TB_NOMBRE% VALUES(%ID%,N'%NAME%',N'%JOB%');" -C
	if errorlevel 1 (
		echo [ERROR] Fallo insertar registro en %TB_NOMBRE% en la base %DB_NOMBRE%.
		pause
		exit /b 1
	)
	goto :eof

REM ----------------------------------------------------
REM Inserta registro con 2 columnas (Id, Nombre)
:INSERT_TO_TABLE_TWOARG
	set "TB_NOMBRE=%~2"
	set "DB_NOMBRE=%~3"
	set "ID=%~5"
	set "NAME=%~6"
	docker exec %CONT_NAME% %SQLCMD_PATH% -S localhost -U SA -P %SA_PASSWORD% -b -d %DB_NOMBRE% -Q "INSERT INTO %TB_NOMBRE% VALUES(%ID%,N'%NAME%');" -C
	if errorlevel 1 (
		echo [ERROR] Fallo insertar registro en %TB_NOMBRE% en la base %DB_NOMBRE%.
		pause
		exit /b 1
	)
	goto :eof

