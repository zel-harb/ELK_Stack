FROM docker.elastic.co/logstash/logstash:9.1.4

USER root

COPY certs /usr/share/logstash/certs
COPY logstash.conf /usr/share/logstash/pipeline/logstash.conf

RUN chown -R logstash:logstash /usr/share/logstash/certs /usr/share/logstash/pipeline/logstash.conf

USER logstash
