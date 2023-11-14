#!/bin/sh
# Path: run.sh

. ./.env

optIn() {
  socket="$NODE_HOSTNAME":"${NODE_DISPERSAL_PORT}"\;"${NODE_RETRIEVAL_PORT}"
  echo "using socket: $socket"
  docker run --env-file .env \
  --volume "${NODE_ECDSA_KEY_FILE_HOST}":/app/operator_keys/ecdsa_key.json \
  --volume "${NODE_BLS_KEY_FILE_HOST}":/app/operator_keys/bls_key.json \
  --volume "${NODE_LOG_PATH_HOST}":/app/logs:rw \
  ghcr.io/layr-labs/eigenda/opr-nodeplugin:release-0.1.0 \
  --operation opt-in \
  --socket "$socket"
}

optOut() {
  docker run --env-file .env \
    --volume "${NODE_ECDSA_KEY_FILE_HOST}":/app/operator_keys/ecdsa_key.json \
    --volume "${NODE_BLS_KEY_FILE_HOST}":/app/operator_keys/bls_key.json \
    --volume "${NODE_LOG_PATH_HOST}":/app/logs:rw \
    ghcr.io/layr-labs/eigenda/opr-nodeplugin:release-0.1.0 \
    --operation opt-out \
    --socket "0"
}

if [ "$1" = "opt-in" ]; then
  optIn
elif [ "$1" = "opt-out" ]; then
  optOut
else
  echo "Invalid command"
fi