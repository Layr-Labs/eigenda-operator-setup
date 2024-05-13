#!/bin/sh
# Path: run.sh

. ./.env

# Initialize variables
NODE_ECDSA_KEY_FILE_HOST=""
NODE_ECDSA_KEY_PASSWORD=""
OPERATION_TYPE=""
QUORUMS=""

# Function to display usage information
show_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help                            Display this help message"
    echo "  --node-ecdsa-key-file-host <path>     Path to the node's ECDSA key file. Required for opt-in, opt-out and update-socket operations"
    echo "  --node-ecdsa-key-password <password>  Password for the node's ECDSA key file. Required for opt-in, opt-out and update-socket operations"
    echo "  --operation-type <operation>          Operation type (opt-in, opt-out, list-quorums, update-socket)"
    echo "  --quorums <quorums>                   Quorum IDs to opt-in or opt-out"
}

# Loop through command-line arguments
while [ $# -gt 0 ]; do
    key="$1"

    case $key in
        -h|--help)
            show_help
            exit 0
            ;;
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
            show_help
            exit 1
            ;;
    esac
    shift
done

# Check if flags are provided
if [ -z "$OPERATION_TYPE" ]; then
    echo "--operation-type is required."
    show_help
    exit 1
fi

if [ "$OPERATION_TYPE" != "list-quorums" ] && [ -z "$NODE_ECDSA_KEY_FILE_HOST" ]; then
    echo "--node-ecdsa-key-file-host is required."
    show_help
    exit 1
fi

if [ "$OPERATION_TYPE" != "list-quorums" ] && [ -z "$NODE_ECDSA_KEY_PASSWORD" ]; then
    echo "--node-ecdsa-key-password is required."
    show_help
    exit 1
fi

if { [ "$OPERATION_TYPE" = "opt-in" ] || [ "$OPERATION_TYPE" = "opt-out" ]; } && [ -z "$QUORUMS" ] ; then
    echo "--quorum is required for opt-in or opt-out operation."
    show_help
    exit 1
fi

socket="$NODE_HOSTNAME":"${NODE_DISPERSAL_PORT}"\;"${NODE_RETRIEVAL_PORT}"

node_plugin_image="ghcr.io/layr-labs/eigenda/opr-nodeplugin:release-0.7.0"

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
  show_helps
fi