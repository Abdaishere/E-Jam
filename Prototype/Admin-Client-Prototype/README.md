# kafka with GUI Client in Electron [![code style: prettier](https://img.shields.io/badge/code_style-prettier-ff69b4.svg?style=flat-square)](https://github.com/prettier/prettier) ![npm version:9.1.3](https://badgen.net/badge/%20/v9.1.3/red?icon=npm)

A Proof of Concept for [Kafka](https://kafka.apache.org/) and [Electronjs](https://www.electronjs.org/).

Having a Kafka Broker in a docker container and producing data to electron client app.

## Kafka Architecture

![alt text](kafka-Architecture.png)

## Prerequisites
- [JDK 19](https://www.oracle.com/java/technologies/javase/jdk19-archive-downloads.html)
- [gradle](https://gradle.org/install/)
- [node](https://nodejs.org/)
- [docker](https://www.docker.com/)

## Running locally

- [./kafka-Docker-Container-and-Java-Producer](kafka-Docker-Container-and-Java-Producer) - Kafka Docker Container and Producer.
- [./Admin-Client-App](Admin-Client-App) - electron GUI and Kafka Consumer

## JSON

For the prototype the topic named `statistics` in the kafka broker receiving data from `generator` and `verifier`
### with
- "id"
- "Date"

That are unique to a specific system
### For verifiers:

- `Source` - verifier's address.
- `Verifier` - true for verifiers.
- `Rate` - rate of transfer per second (download per second).
- `Total` - total received packets.
- `Errortotal` - rejected packets

```json
{
  "Source": "xx-xx-xx-xx-xx-xx",
  "Verifier": true,
  "Rate": 30,
  "Total": 54344,
  "ErrorTotal": 554
}
```

### For generators:

- `Source` - generator's address.
- `Verifier` - false for generators.
- `Rate` - rate of transfer per second (upload per second).
- `Total` - total sent packets.

```json
{
  "Source": "xx-xx-xx-xx-xx-xx",
  "Verifier": false,
  "Rate": 30,
  "Total": 353287654,
  "ErrorTotal": null
}
```

## avro

Using avsc package for serialization and deserialization
It uses `JSON` for defining data types and protocols, and `serializes` data in a `compact binary format`.

[Apache Avro™](https://avro.apache.org/) is the leading `serialization` format for record data, and first choice
for `streaming` data pipelines.

from file in schema regirsy in the docker contaitner [statistics_value.avsc](kafka-Docker-Container-and-Java-Producer\Avro\app\src\main\avro\statistics_value.avsc)

```json
{
  "namespace": "com.ejam.avro.statistics",
  "type": "record",
  "name": "statisticsValue",
  "fields": [
    {
      "name": "ErrorTotal",
      "type": [
        "null",
        "int"
      ],
      "default": null
    },
    {
      "name": "Rate",
      "type": [
        "null",
        "int"
      ],
      "default": null
    },
    {
      "name": "id",
      "type": "string"
    },
    {
      "name": "Source",
      "type": [
        "null",
        "string"
      ],
      "default": null
    },
    {
      "name": "Total",
      "type": [
        "null",
        "int"
      ],
      "default": null
    },
    {
      "name": "Date",
      "type": {
        "type": "long",
        "logicalType": "local-timestamp-millis"
      }
    },
    {
      "name": "Verifier",
      "type": "boolean"
    }
  ]
}
```

#### Notice: the `Source's` can be set to macaddress which gets it from `node-macaddress` package or as a constant string

## Further readings

- https://hub.docker.com/r/bitnami/kafka
- https://www.npmjs.com/package/node-rdkafka
- https://en.wikipedia.org/wiki/Apache_Avro
- https://www.npmjs.com/package/avsc
