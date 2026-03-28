#!/bin/bash
set -e

JOIN_SCRIPT="/vagrant/join.sh"
TIMEOUT=300
ELAPSED=0

echo "[WORKER] Waiting for join script from master..."

while [ ! -f ${JOIN_SCRIPT} ]; do
    if [ ${ELAPSED} -ge ${TIMEOUT} ]; then
        echo "[WORKER] ERROR: Timed out after ${TIMEOUT}s waiting for join script. Is the master provisioned?"
        exit 1
    fi
    sleep 5
    ELAPSED=$((ELAPSED + 5))
done

echo "[WORKER] Join script found. Joining cluster..."

RETRIES=3
for i in $(seq 1 ${RETRIES}); do
    if bash ${JOIN_SCRIPT}; then
        echo "[WORKER] Successfully joined the cluster"
        exit 0
    fi
    echo "[WORKER] Join attempt ${i}/${RETRIES} failed, retrying in 15s..."
    sleep 15
done

echo "[WORKER] ERROR: Failed to join cluster after ${RETRIES} attempts"
exit 1
