# Makefile

all: buildCpp buildSysApi createFiles
	echo done building	

# Execute the CMakeLists file to build the other 3 targets
buildCpp:
	cd Executables && cmake . && make
	echo done building cpp

# Build the SystemApi
buildSysApi:
	cd SystemApi && sudo mvn clean install
	echo done building sysApi

createFiles: 
	sudo mkdir -p /etc/EJam/stats/genStats
	sudo mkdir -p /etc/EJam/stats/verStats
	sudo touch /etc/EJam/interfaces.txt
	sudo touch /etc/EJam/admin_config.txt			
	echo done creating files

# Clean unwanted files
clean:
	cd SystemApi && mvn clean
	cd Executables && make clean
