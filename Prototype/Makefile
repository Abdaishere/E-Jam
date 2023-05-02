# Makefile

# Execute the CMakeLists file to build the other 3 targets
buildCpp:
	cd Executables && cmake . && make

# Build the SystemApi
buildSysApi:
	cd SystemApi && mvn package


# Clean unwanted files
clean:
	cd SystemApi && mvn clean
	cd Executables && make clean
