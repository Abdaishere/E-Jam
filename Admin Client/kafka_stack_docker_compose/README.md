# A docker compose file to run Kafka with a graphical desktop user interface for Apache Kafka

Once you have started your cluster, you can use Conduktor to easily manage it.
Just connect against `localhost:9092`. If you are on Mac or Windows and want to connect from another container, use `host.docker.internal:29092`

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

 Run with:

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

## Advanced usage

## Create a consumer for Avro data in "my_avro_consumer_group" consumer group, starting at the beginning of the topic's

## log and subscribe to a topic. Then consume some data from a topic, which is decoded, translated to

## JSON, and included in the response. The schema used for deserialization is

## fetched automatically from schema registry. Finally, clean up

curl -X POST  -H "Content-Type: application/vnd.kafka.v2+json" \
      --data '{"name": "my_consumer_instance", "format": "avro", "auto.offset.reset": "earliest"}' \
      <http://localhost:8082/consumers/my_avro_consumer_group>

## Expected output from preceding command

  {"instance_id":"my_consumer_instance","base_uri":"<http://localhost:8082/consumers/my_avro_consumer_group/instances/my_consumer_instance"}>

curl -X POST -H "Content-Type: application/vnd.kafka.v2+json" --data '{"topics":["avrotest"]}' \
      <http://localhost:8082/consumers/my_avro_consumer_group/instances/my_consumer_instance/subscription>

## No content in response

curl -X GET -H "Accept: application/vnd.kafka.avro.v2+json" \
      <http://localhost:8082/consumers/my_avro_consumer_group/instances/my_consumer_instance/records>

## Expected output from preceding command (note that the actual output will contain different data)

  [{"key":null,"value":{"name":"testUser"},"partition":0,"offset":1,"topic":"avrotest"}]

curl -X DELETE -H "Content-Type: application/vnd.kafka.v2+json" \
      <http://localhost:8082/consumers/my_avro_consumer_group/instances/my_consumer_instance>

## No content in response if successful
