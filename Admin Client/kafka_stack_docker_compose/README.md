
# A docker compose file to run Kafka with a graphical desktop user interface for Apache Kafka

## how to run kafka stack in docker

the Following instructions can be applied on the CLI or using Conduktor Platform (recommended) which you can find out more about in the ##Full stack section

Make sure you have docker and docker-compose installed on your machine

```bash
docker-compose up -d # run in background
```

After that you can either open Conduktor Platform and add the two schemas to the Schema Registry, or you can use the Conduktor CLI to do it:

```bash
conduktor schema-registry add --name Verifier --schema-file ./avro/verifiers.avsc --schema-type avro --schema-description "Verifier schema"
conduktor schema-registry add --name Generator --schema-file ./avro/generators.avsc --schema-type avro --schema-description "Generator schema"
```

Don't forget to add the two Topics Verifier and Generator as well

```bash
conduktor topic add --name Verifier --partitions 1 --replication-factor 1
conduktor topic add --name Generator --partitions 1 --replication-factor 1
```

if all didn't work you can run a small version of the SystemApi that is responsible for producing the actual statistics which will automatically register the schemas in the schema registry

```bash
cd SystemApi
mvn clean install
mvn exec:java
```

Once you have started your cluster, you can use Conduktor to easily manage it.
Just connect against `localhost:9092`. If you are on Mac or Windows and want to connect from another container, use `host.docker.internal:29092`

If you want more info checkout the rest of the readme.

## kafka-stack-docker-compose

This replicates as well as possible real deployment configurations, where you have your zookeeper servers and kafka servers actually all distinct from each other. This solves all the networking hurdles that comes with Docker and docker-compose, and is compatible cross platform.

## Start the ksqlDB CLI

ksqlDB runs as a server which clients connect to in order to issue queries.

Run this command to connect to the ksqlDB server and enter an interactive command-line interface (CLI) session.

for more info see [ksqlDB CLI](https://docs.ksqldb.io/en/latest/developer-guide/ksqldb-reference/cli/)

```bash
docker-compose exec ksqldb-cli ksql http://ksqldb-server:8088
```

## Stack version

- Conduktor Platform: latest
- Zookeeper version: 3.6.3 (Confluent 7.3.2)
- Kafka version: 3.3.0 (Confluent 7.3.2)
- Kafka Schema Registry: Confluent 7.3.2
- Kafka Rest Proxy: Confluent 7.3.2
- Kafka Connect: Confluent 7.3.2
- ksqlDB Server: Confluent 7.3.2
- Zoonavigator: 1.1.1

For a UI tool to access your local Kafka cluster, use [Conduktor](https://www.conduktor.io/get-started)

## Requirements

Kafka will be exposed on `127.0.0.1` or `DOCKER_HOST_IP` if set in the environment.
(You probably don't need to set it if you're not using Docker-Toolbox)

## Full stack

To ease you journey with kafka just connect to [localhost:8080](http://localhost:8080/)

login: `admin@admin.io`
password: `admin`

- Conduktor-platform: `$DOCKER_HOST_IP:8080`
- Single Zookeeper: `$DOCKER_HOST_IP:2181`
- Single Kafka: `$DOCKER_HOST_IP:9092`
- Kafka Schema Registry: `$DOCKER_HOST_IP:8081`
- Kafka Rest Proxy: `$DOCKER_HOST_IP:8082`
- Kafka Connect: `$DOCKER_HOST_IP:8083`
- KSQL Server: `$DOCKER_HOST_IP:8088`
- JMX port at `$DOCKER_HOST_IP:9001`

 Stop with:

 ```bash
 docker-compose up
 docker-compose down
 ```

** Note: if you find that you can not connect to [localhost:8080](http://localhost:8080/) please run `docker-compose build` to rebuild the port mappings.

## Testing

Some basic tests are included to verify that the stack is working once up.

```bash
./test.sh docker-compose.yml
```
