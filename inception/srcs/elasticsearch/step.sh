#!/bin/bash
set -e

# Start Elasticsearch in the background and capture its output
echo "Starting Elasticsearch..."
/usr/local/bin/docker-entrypoint.sh elasticsearch &
ES_PID=$!

# Give it a moment to start
sleep 5

# Check if the process is still running
if ! kill -0 $ES_PID 2>/dev/null; then
    echo "ERROR: Elasticsearch process died during startup"
    wait $ES_PID
    exit 1
fi

# Wait until Elasticsearch answers on HTTPS (with timeout)
echo "Waiting for Elasticsearch to be ready on https://localhost:9200 ..."
MAX_WAIT=120
COUNTER=0
until curl -ks -u "elastic:${ELASTIC_PASSWORD}" \
      https://localhost:9200/_cluster/health >/dev/null 2>&1; do
  
  # Check if ES process is still alive
  if ! kill -0 $ES_PID 2>/dev/null; then
      echo "ERROR: Elasticsearch process died while waiting for it to be ready"
      exit 1
  fi
  
  COUNTER=$((COUNTER + 2))
  if [ $COUNTER -ge $MAX_WAIT ]; then
      echo "ERROR: Elasticsearch did not become ready within ${MAX_WAIT} seconds"
      echo "Checking Elasticsearch logs..."
      tail -100 /usr/share/elasticsearch/logs/*.log 2>/dev/null || echo "No logs found"
      exit 1
  fi
  
  sleep 2
done
echo "Elasticsearch is ready!"

# Change the kibana_system password
echo "Setting kibana_system password..."
curl -ks -X POST -u "elastic:${ELASTIC_PASSWORD}" \
     -H 'Content-Type: application/json' \
     https://localhost:9200/_security/user/kibana_system/_password \
     -d "{\"password\":\"${KIBANA_SYSTEM_PASSWORD}\"}" || true
echo "kibana_system password set successfully!"

# Keep the container alive
wait $ES_PID
