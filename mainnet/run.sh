#!/bin/sh
# Path: run.sh

. ./.env

socket="$NODE_HOSTNAME":"${NODE_DISPERSAL_PORT}"\;"${NODE_RETRIEVAL_PORT}"

node_plugin_image="ghcr.io/layr-labs/eigenda/opr-nodeplugin:0.7.0"

# In all commands, We have to explicitly set the password again here because
# when docker run loads the `.env` file, it keeps the quotes around the password
# which causes the password to be incorrect.
# To test that try running `docker run --rm --env-file .env busybox /bin/sh -c 'echo $NODE_ECDSA_KEY_PASSWORD'`
# This will output password with single quote. Not sure why this happens.
optIn() {
  echo "using socket: $socket"
  docker run --env-file .env \
  --rm \
#   --volume "${NODE_ECDSA_KEY_FILE_HOST}":/app/operator_keys/ecdsa_key.json \
  --volume "${NODE_BLS_KEY_FILE_HOST}":/app/operator_keys/bls_key.json \
  --volume "${NODE_LOG_PATH_HOST}":/app/logs:rw \
  "$node_plugin_image" \
  --ecdsa-key-password "$NODE_ECDSA_KEY_PASSWORD" \
  --bls-key-password "$NODE_BLS_KEY_PASSWORD" \
  --operation opt-in \
  --socket "$socket" \
  --quorum-id-list "$1"
}

optOut() {
  docker run --env-file .env \
    --rm \
    # --volume "${NODE_ECDSA_KEY_FILE_HOST}":/app/operator_keys/ecdsa_key.json \
    --volume "${NODE_BLS_KEY_FILE_HOST}":/app/operator_keys/bls_key.json \
    --volume "${NODE_LOG_PATH_HOST}":/app/logs:rw \
    "$node_plugin_image" \
    --ecdsa-key-password "$NODE_ECDSA_KEY_PASSWORD" \
    --bls-key-password "$NODE_BLS_KEY_PASSWORD" \
    --operation opt-out \
    --socket "$socket" \
    --quorum-id-list "$1"
}

listQuorums() {
  # we have to pass a dummy quorum-id-list as it is required by the plugin
  docker run --env-file .env \
    --rm \
    # --volume "${NODE_ECDSA_KEY_FILE_HOST}":/app/operator_keys/ecdsa_key.json \
    --volume "${NODE_BLS_KEY_FILE_HOST}":/app/operator_keys/bls_key.json \
    --volume "${NODE_LOG_PATH_HOST}":/app/logs:rw \
    "$node_plugin_image" \
    --ecdsa-key-password "$NODE_ECDSA_KEY_PASSWORD" \
    --bls-key-password "$NODE_BLS_KEY_PASSWORD" \
    --socket "$socket" \
    --operation list-quorums \
    --quorum-id-list 0
}

updateSocket() {
  # we have to pass a dummy quorum-id-list as it is required by the plugin
  docker run --env-file .env \
    --rm \
    # --volume "${NODE_ECDSA_KEY_FILE_HOST}":/app/operator_keys/ecdsa_key.json \
    --volume "${NODE_BLS_KEY_FILE_HOST}":/app/operator_keys/bls_key.json \
    --volume "${NODE_LOG_PATH_HOST}":/app/logs:rw \
    "$node_plugin_image" \
    --ecdsa-key-password "$NODE_ECDSA_KEY_PASSWORD" \
    --bls-key-password "$NODE_BLS_KEY_PASSWORD" \
    --socket "$socket" \
    --operation update-socket \
    --quorum-id-list 0
}

if [ "$1" = "opt-in" ]; then
  if [ -z "$2" ]; then
    echo "Please provide quorum number (0/1/0,1)"
    echo "Example Usage: ./run.sh opt-in 0"
    exit 1
  fi
  optIn "$2"
elif [ "$1" = "opt-out" ]; then
  if [ -z "$2" ]; then
    echo "Please provide quorum number (0/1/0,1)"
    echo "Example Usage: ./run.sh opt-out 0"
    exit 1
  fi
  optOut "$2"
elif [ "$1" = "list-quorums" ]; then
  listQuorums
elif [ "$1" = "update-socket" ]; then
  updateSocket
else
  echo "Invalid command"
fi
