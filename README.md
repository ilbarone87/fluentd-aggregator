Fluentd log aggregator
=========

Fluentd customized docker image for being deployed as log aggregator in Fluentbit/Fluentd forwarder/aggregation architecture pattern.

Based on official [fluentd docker image](https://github.com/fluent/fluentd-docker-image), plugins have been added and default configuration has been included.


Plugins Added
------------

The follogin plugins has been added to the default fluentd image
- fluent-plugin-elasticsearch: ES as backend for routing the logs
- fluent-plugin-prometheus: Enabling prometheus monitoring 


Default Fluentd Configuration
--------------

Fluentd is configured:

 - to export Prometheus metrics. See [fluentd documentation] (https://docs.fluentd.org/monitoring-fluentd/monitoring-prometheus)

 - to collect logs from forwarders (Fluentbit/Fluentd in forwarding mode)

 - to route all logs to Elasticsearch backend


Multi-architecture build
--------------
Github actions have been configured to automatically build amd64 and arm64 docker images.

This images are available in docker hub https://hub.docker.com/r/ricsanfre/fluentd-aggregator

How to use this image
--------------

To create an aggregator that collects logs from other forwarders

docker run -d -p 24224:24224 -p 24224:24224/udp ricsanfre/fluentd-aggregator:latest
