#!/bin/bash

APM_SERVER_URL="http://localhost:8200"
SECRET_TOKEN="Zi07Ksmqd1iCFyOlFWhGnhuP1KHg8fSaxx"
SERVICE_NAME="test-service"
ENVIRONMENT="development"
name="application-test"

TRACE_ID=$(uuidgen | tr -d '-' | cut -c1-32)
TX_ID=$(uuidgen | tr -d '-' | cut -c1-32)
SPAN_ID=$(uuidgen | tr -d '-' | cut -c1-16)

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)
echo "Timestamp is:: $TIMESTAMP"

PAYLOAD=$(cat <<EOF
{"metadata":{"service":{"name":"$SERVICE_NAME","environment":"$ENVIRONMENT","agent":{"name":"bash","version":"1.0.0"}}}}
{"transaction":{"id":"$TX_ID","trace_id":"$TRACE_ID","name":"$name","type":"request","duration":150.5,"timestamp":"$TIMESTAMP","result":"success","span_count":{"started":1},"context":{"service":{"name":"$SERVICE_NAME","environment":"$ENVIRONMENT"}}}}
{"span":{"id":"$SPAN_ID","transaction_id":"$TX_ID","trace_id":"$TRACE_ID","parent_id":"$TX_ID","name":"sample-span","type":"custom","duration":50.0,"timestamp":"$TIMESTAMP"}}
EOF
)

echo "Payload:"
echo "$PAYLOAD"

RESPONSE=$(curl -v -s -w "\n%{http_code}" -X POST "$APM_SERVER_URL/intake/v2/events" \
  -H "Content-Type: application/x-ndjson" \
  -H "Authorization: Bearer $SECRET_TOKEN" \
  --data "$PAYLOAD" 2>&1)

HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed -e '$d')

echo "HTTP Status:::: $HTTP_STATUS"
echo "Server response::: $RESPONSE_BODY"
echo "done!"