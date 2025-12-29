#!/bin/bash
set -e

# 1.  Start the original Elasticsearch entry-point in the background
#     (it keeps the container alive)
/usr/local/bin/docker-entrypoint.sh elasticsearch &
ES_PID=$!

# 2.  Wait until Elasticsearch answers on HTTPS
echo "Waiting for Elasticsearch to be ready on https://localhost:9200 ..."
until curl -ks -u "elastic:${ELASTIC_PASSWORD}" \
      https://localhost:9200/_cluster/health >/dev/null 2>&1; do
  sleep 2
done
echo "Elasticsearch is ready!"

# 3.  Change the kibana_system password (idempotent – OK if it already exists)
echo "Setting kibana_system password..."
curl -ks -X POST -u "elastic:${ELASTIC_PASSWORD}" \
     -H 'Content-Type: application/json' \
     https://localhost:9200/_security/user/kibana_system/_password \
     -d "{\"password\":\"${KIBANA_SYSTEM_PASSWORD}\"}" || true
echo "kibana_system password set successfully!"

# 4.  Keep the container alive (foreground the original process)
wait $ES_PID