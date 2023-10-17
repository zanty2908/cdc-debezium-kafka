#!/bin/bash

# if [ "$#" -ne 1 ]; then
#     echo "Usage: $0 <debezium_base_url>"
#     exit 1
# fi

DEBEZIUM_BASE_URL="localhost:8083"
CONNECTORS=$(curl -s "${DEBEZIUM_BASE_URL}/connectors/")

while true; do
    echo "Connector ${CONNECTORS} is running."
    for CONNECTOR_NAME in $(echo "${CONNECTORS}" | awk -F'"' '{ for (i=2; i<NF; i+=2) print $i }'); do
        STATUS=$(curl -s "${DEBEZIUM_BASE_URL}/connectors/${CONNECTOR_NAME}/status" | grep -o RUNNING | wc -l)
        
        if [ "$STATUS" -eq 2 ]; then
            echo "Connector ${CONNECTOR_NAME} is running."
        else
            echo "Connector ${CONNECTOR_NAME} is not running. Restarting..."
            curl -X POST "${DEBEZIUM_BASE_URL}/connectors/${CONNECTOR_NAME}/restart"
        fi
    done

    sleep 300  # 300 seconds (5 minutes)
done
echo "Done...."
