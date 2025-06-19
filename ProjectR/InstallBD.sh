#!/bin/bash

# Detener la ejecucion en caso de error
set -euo pipefail

echo "Iniciando proceso de preparacion del entorno"


# 1.- Configuracion de funciones


#Funcion para checkear la correcta instalacion de las dependencias
function check_command(){
	command -v "$1" &>/dev/null
	}
	
#Funcion para corroborar si esta instalado o es necesaria la instalacion de cada dependencia

function install_package(){
	local pkg=$1
	if dpkg -s "$pkg" &>/dev/null; then
		echo "$pkg ya esta instalado."
	else 
		echo "Instalando $pkg..."
		sudo apt-get install -y "$pkg"
		echo "$pkg Instalado"
	fi
	}
	
#Funcion para instalar java ya que no se encuentra en kali por defecto

function install_openjdk17(){

	echo "Verificando si Java se encuentra instalado"
	
	if check_command java; then
		echo "Java 17 se encuentra instalado"
		java -version
		return
	fi
	
	echo "Intentando instalar OpenJDK 17 con APT"
	
	if sudo apt-get install -y openjdk-17-jdk; then
		echo "OpenJDK 17 instalado correctamente desde los repositorios"
		return 0
	else
		echo "No se pudo instalar. Iniciando instalacion Manual."
		
		#Variables
		JDK_VERSION="17"
		JDK_URL=$(curl -s "https://api.adoptium.net/v3/assets/latest/${JDK_VERSION}/hotspot?os=linux&architecture=x64&image_type=jdk" | jq -r '.[0].binary.package.link' | head -n 1)
		JDK_DIR="/opt/java"
		JDK_NAME="jdk-$JDK_VERSION"
		
		#Crear carpeta de instalacion
		sudo mkdir -p "$JDK_DIR"
		cd /tmp
		
		#Descargar y extraer
		echo "descarga desde: $JDK_URL"
		curl -L "$JDK_URL" -o "$JDK_NAME.tar.gz"
		sudo tar -xzf "$JDK_NAME.tar.gz" -C "$JDK_DIR"
		rm "$JDK_NAME.tar.gz"
		echo "Descarga exitosa"
		
		#Buscar Carpeta y configurar updates alternativas
		JDK_PATH=$(find "$JDK_DIR" -type f -name "java" | sed 's|/bin/java||' | head -n 1)
		sudo update-alternatives --install /usr/bin/java java "$JDK_PATH" 1
		JDK_PATH=$(find "$JDK_DIR" -type f -name "javac" | sed 's|/bin/javac||' | head -n 1)
		sudo update-alternatives --install /usr/bin/javac javac "$JDK_PATH" 1
		
		#Configurar JAVA_HOME para la sesion actual
		export JAVA_HOME="$JDK_PATH"
		export PATH="$JAVA_HOME/bin:$PATH"
		
		echo "OpenJDK 17 instalado manualmente"
		
		java -version
	fi
}
#Funcion para ejecutar y corroborar que los servicios se esten ejecutando de manera correcta
	
function ensure_service_running(){
	local service=$1
	echo "Verificando estado de $service ..."
	if ! sudo systemctl is-active --quiet "$service"; then
		echo "Iniciando $service..."
		sudo systemctl start "service"
		sudo systemctl enable "$service"
	else 
		echo "$service esta activo."
	fi
	}
	
#Funciones esteticas

function crono_ins(){
	echo "continuando en:"
	for i in {3..1}; do
		echo -n "$i..."
		sleep 1
	done
	echo -e "\n Continuando"
	}

# Iniciando proceso de instalacion de dependencias

echo "Update y upgrade rutinario"
sudo apt-get update -y
sudo apt-get upgrade -y

#Instalacion de dependencias
install_package jq
crono_ins
install_package curl
crono_ins
install_package unzip 
crono_ins
install_openjdk17
crono_ins
install_package maven
crono_ins
install_package git
crono_ins
install_package docker.io
crono_ins




#Verificacion

for cmd in java mvn docker git curl; do 
	if check_command "$cmd"; then
		echo "Comando '$cmd' disponible en el sistema."
	else
		echo "Comando '$cmd' no disponible. Algo fallo en la instalacion."
		exit 1
	fi
done


#Iniciando servicios de docker

ensure_service_running docker

#Agregando usuario a docker

if groups "$USER" | grep -qv '\bdocker\b'; then
	echo "agregando $USER al grupo docker"
	sudo usermod -aG docker "$USER"
	echo "Cierra sesion y vuelve a iniciar para aplicar cambios de grupo."
	
else
	echo "Usuario $USER ya pertenece al grupo docker"
fi
sudo docker start sqlserver
#Instalar y arrancar sql server en docker
if ! sudo docker ps | grep -q 'sqlserver'; then
	echo "Iniciando contenedor Docker de SQL Server"
	sudo docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=Test!12345' -p 1433:1433 --name sqlserver -d mcr.microsoft.com/mssql/server:2019-latest
	
else 
	echo "Contenedor SQL Server ya corriendo"
fi

echo "Finalizada la fase de configuracion de entorno"

#Creacion de BD y tablas en la BD


#variables
PASSW='Test!12345'
CONT_NAME='sqlserver'

sudo docker exec -it sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P 'Test!12345' -Q "SELECT @@VERSION" -C -N
sudo docker exec $CONT_NAME /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P $PASSW -Q "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'BaseDatosUno') 
																				BEGIN
																				  CREATE DATABASE BaseDatosUno;
																				  PRINT 'Base de datos Uno creada.';
																				 END
																				 ELSE
																				 BEGIN
																				  PRINT 'Base de datos Uno ya existe';
																				 END" -C
sudo docker exec $CONT_NAME /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P $PASSW -Q "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'BaseDatosDos') 
																				BEGIN
																				  CREATE DATABASE BaseDatosDos;
																				  PRINT 'Base de datos Dos creada.';
																				END
																				ELSE
																				BEGIN
																				  PRINT 'Base de datos Dos ya existe';
																				 END" -C

#Crear tablas en la primera base de datos
sudo docker exec $CONT_NAME /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P $PASSW -d BaseDatosUno -Q "CREATE TABLE Empleados(
													Id INT PRIMARY KEY,
													Nombre NVARCHAR(100),
													Cargo NVARCHAR(100)
													);" -C

sudo docker exec $CONT_NAME /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P $PASSW -d BaseDatosUno -Q "INSERT INTO Empleados (Id,Nombre,Cargo) VALUES
													(1, N'Juan Pérez', N'Ingeniero'),
													(2, N'Anna Soto', N'Analista'),
													(3, N'Pedro Gonzalez', N'QA')
													;" -C
											
sudo docker exec $CONT_NAME /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P $PASSW -d BaseDatosDos -Q "CREATE TABLE Departamentos(
													Id INT PRIMARY KEY,
													Nombre NVARCHAR(100),
													);" -C

sudo docker exec $CONT_NAME /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P $PASSW -d BaseDatosDos -Q "INSERT INTO Departamentos (Id,Nombre) VALUES
													(1, N'TI'),
													(2, N'RRHH'),
													(3, N'Gerencia')
													;" -C

#Consultas de prueba
echo "Corroborando funcionamiento de BD"

sudo docker exec $CONT_NAME /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P $PASSW -d BaseDatosUno -Q "Select * From Empleados;" -C

sudo docker exec $CONT_NAME /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P $PASSW -d BaseDatosDos -Q "Select * From Departamentos;" -C

#Comenzado instalacion de IDE
echo "instalando IntelliJ"

echo "Se iniciara el proceso de instalado de snap, favor reiniciar el SO una vez termine y luego volver a correr el codigo"
sleep 5

if ! command -v sna &>/dev/null; then
	echo 'instalando snapd'
	sudo apt update
	sudo apt install -y snapd
	sudo systemctl enable --now snapd.socket
	if [ ! -e /snap ]; then
		sudo ln -s /var/lib/snapd/snap /snap
	else
		echo "Enlace snap ya existente"
	fi 
fi

sudo snap install intellij-idea-community --classic
echo 'IntelliJ Idea instalado'
