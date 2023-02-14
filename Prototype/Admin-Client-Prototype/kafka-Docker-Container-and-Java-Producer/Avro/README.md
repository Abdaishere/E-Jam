## **Building Avro Java Classes**
[See all Schemas in avro folder](\app\src\main\avro)


### **Java Class Genration**
### Option One
`java -jar <path/to/avro-tools-1.9.1.jar> compile schema <path/to/schema-file> <destination-folder>`

example:
- `java -jar ".\jars\avro-tools-1.9.1.jar" compile schema ".\app\src\main\avro" "..\producer\Kafka-Producer\app\src\main\java"`

### Option Two (using [davidmc24's gradle-avro-plugin](https://github.com/davidmc24/gradle-avro-plugin))
Or you can build a gradle app with  id "com.github.davidmc24.gradle.plugin.avro" version "1.5.0" after puting the "avro" file in "src", and get the output .java files or the schemas
 
example:
- `./gradlew build`
- output will be in [.\app\build\generated-main-avro-java\com\ejam\avro](.\app\build\generated-main-avro-java\com\ejam\avro)