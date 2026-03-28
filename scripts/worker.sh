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
bash ${JOIN_SCRIPT}

echo "[WORKER] Successfully joined the cluster"
