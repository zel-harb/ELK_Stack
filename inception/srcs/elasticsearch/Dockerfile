FROM docker.elastic.co/elasticsearch/elasticsearch:9.1.4

USER root

# Copy files
COPY elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
COPY step.sh /usr/local/bin/step.sh
COPY certs /usr/share/elasticsearch/config/certs

# Set correct permissions and ownership
RUN chmod +x /usr/local/bin/step.sh && \
    chown elasticsearch:elasticsearch /usr/share/elasticsearch/config/elasticsearch.yml && \
    chown elasticsearch:elasticsearch /usr/local/bin/step.sh && \
    chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/config/certs

USER elasticsearch
EXPOSE 9200
ENTRYPOINT ["/usr/local/bin/step.sh"]