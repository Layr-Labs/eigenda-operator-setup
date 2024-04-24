#!/bin/sh
# Path: run.sh

. ./.env

# Initialize variables
NODE_ECDSA_KEY_FILE_HOST=""
NODE_ECDSA_KEY_PASSWORD=""
OPERATION_TYPE=""
QUORUMS=""

# Loop through command-line arguments
# shellcheck disable=SC2039
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --node-ecdsa-key-file-host)
            NODE_ECDSA_KEY_FILE_HOST="$2"
            shift
            ;;
        --node-ecdsa-key-password)
            NODE_ECDSA_KEY_PASSWORD="$2"
            shift
            ;;
        --operation-type)
            OPERATION_TYPE="$2"
            shift
            ;;
        --quorums)
            QUORUMS="$2"
            shift
            ;;
        *)  # Unknown flag
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Check if flags are provided
if [ -z "$OPERATION_TYPE" ]; then
    echo "--operation-type is required."
    exit 1
fi

if [ "$OPERATION_TYPE" != "list-quorums" ] && [ -z "$NODE_ECDSA_KEY_FILE_HOST" ]; then
    echo "--node-ecdsa-key-file-host is required."
    exit 1
fi

if [ "$OPERATION_TYPE" != "list-quorums" ] && [ -z "$NODE_ECDSA_KEY_PASSWORD" ]; then
    echo "--node-ecdsa-key-password is required."
    exit 1
fi

if { [ "$OPERATION_TYPE" = "opt-in" ] || [ "$OPERATION_TYPE" = "opt-out" ]; } && [ -z "$QUORUMS" ] ; then
    echo "--quorum is required for opt-in or opt-out operation."
    exit 1
fi

socket="$NODE_HOSTNAME":"${NODE_DISPERSAL_PORT}"\;"${NODE_RETRIEVAL_PORT}"

node_plugin_image="ghcr.io/layr-labs/eigenda/opr-nodeplugin:release-0.6.2"

# In all commands, We have to explicitly set the password again here because
# when docker run loads the `.env` file, it keeps the quotes around the password
# which causes the password to be incorrect.
# To test that try running `docker run --rm --env-file .env busybox /bin/sh -c 'echo $NODE_ECDSA_KEY_PASSWORD'`
# This will output password with single quote. Not sure why this happens.
optIn() {
  echo "using socket: $socket"
  docker run --env-file .env \
  --rm \
  --volume "${NODE_ECDSA_KEY_FILE_HOST}":/app/operator_keys/ecdsa_key.json \
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
    --volume "${NODE_ECDSA_KEY_FILE_HOST}":/app/operator_keys/ecdsa_key.json \
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
    --volume "${NODE_ECDSA_KEY_FILE_HOST}":/app/operator_keys/ecdsa_key.json \
    --volume "${NODE_BLS_KEY_FILE_HOST}":/app/operator_keys/bls_key.json \
    --volume "${NODE_LOG_PATH_HOST}":/app/logs:rw \
    "$node_plugin_image" \
    --ecdsa-key-password "$NODE_ECDSA_KEY_PASSWORD" \
    --bls-key-password "$NODE_BLS_KEY_PASSWORD" \
    --socket "$socket" \
    --operation update-socket \
    --quorum-id-list 0
}

if [ "$OPERATION_TYPE" = "opt-in" ]; then
  echo "Opting in"
  optIn "$QUORUMS"
elif [ "$OPERATION_TYPE" = "opt-out" ]; then
  echo "Opting out"
  optOut "$QUORUMS"
elif [ "$OPERATION_TYPE" = "list-quorums" ]; then
  echo "Listing quorums"
  listQuorums
elif [ "$OPERATION_TYPE" = "update-socket" ]; then
  echo "Updating socket"
  updateSocket
else
  echo "Invalid command"
fi