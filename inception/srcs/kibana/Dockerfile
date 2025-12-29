FROM docker.elastic.co/kibana/kibana:9.1.4


USER root

COPY certs /usr/share/kibana/config/certs
COPY kibana.yml /usr/share/kibana/config/kibana.yml

RUN chown -R kibana:kibana /usr/share/kibana/config \
 && chmod 750 /usr/share/kibana/config/certs \
 && chmod 640 /usr/share/kibana/config/certs/* \
 && chmod 640 /usr/share/kibana/config/kibana.yml

USER kibana

EXPOSE 5601