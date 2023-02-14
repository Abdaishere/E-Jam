# node-kafka Broker and Producer

Run kafka broker on the [docker container](docker-compose.yml) and, test using the [producer](\producer\README.md) in
nodejs

### Prerequisites:
- [JDK 19](https://www.oracle.com/java/technologies/javase/jdk19-archive-downloads.html)
- [gradle](https://gradle.org/install/)
- [docker](https://www.docker.com/)

### Running locally:
`docker compose up` to start kafka inside docker container.

### Create topic:
`docker exec -it broker kafka-topics --bootstrap-server broker:9092 --create --topic statistics --partitions 1 --replication-factor 1`

### List topic:
`docker exec -it broker kafka-topics --bootstrap-server broker:9092 --list`

### verify that Avro based Order records are making it into Kafka: 
`docker exec -it schema-registry kafka-avro-console-consumer --bootstrap-server broker:29092 --from-beginning --topic statistics --property schema.registry.url=http://schema-registry:8081`


### Run producer:
`./producer/Kafka-Producer/gradlew run`

### Using the HttpPie HTTP CLI client but or use curl or Postman use the Confluent Schema Registry REST API to inspect the data its managing for schemas:
`GET http://localhost:8081/schemas`

And you can use Offset Explorer 2.3


