#!/bin/bash
set -e

JOIN_SCRIPT="/vagrant/join.sh"

echo "[WORKER] Waiting for join script from master..."

while [ ! -f ${JOIN_SCRIPT} ]; do
    sleep 5
done

echo "[WORKER] Join script found. Joining cluster..."
bash ${JOIN_SCRIPT}

echo "[WORKER] Successfully joined the cluster"
