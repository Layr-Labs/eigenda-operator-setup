#!/bin/sh
# Path: run.sh

. ./.env

socket="$NODE_HOSTNAME":"${NODE_DISPERSAL_PORT}"\;"${NODE_RETRIEVAL_PORT}"

# In all commands, We have to explicitly set the password again here because
# when docker run loads the `.env` file, it keeps the quotes around the password
# which causes the password to be incorrect.
# To test that try running `docker run --rm --env-file .env busybox /bin/sh -c 'echo $NODE_ECDSA_KEY_PASSWORD'`
# This will output password with single quote. Not sure why this happens.
optIn() {
  echo "checking and validating SRS"
  ../srs_setup.sh
  if [ $? -ne 0 ]; then
    echo "Error: SRS setup failed. Exiting."
    exit 1
  fi
  echo "using socket: $socket"
  docker run --env-file .env \
  --rm \
  --volume "${NODE_ECDSA_KEY_FILE_HOST}":/app/operator_keys/ecdsa_key.json \
  --volume "${NODE_BLS_KEY_FILE_HOST}":/app/operator_keys/bls_key.json \
  --volume "${NODE_LOG_PATH_HOST}":/app/logs:rw \
  ghcr.io/layr-labs/eigenda/opr-nodeplugin:release-0.6.0 \
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
    ghcr.io/layr-labs/eigenda/opr-nodeplugin:release-0.6.0 \
    --ecdsa-key-password "$NODE_ECDSA_KEY_PASSWORD" \
    --bls-key-password "$NODE_BLS_KEY_PASSWORD" \
    --operation opt-out \
    --socket "$socket" \
    --quorum-id-list "$1"
}


if [ "$1" = "opt-in" ]; then
  optIn "$2"
elif [ "$1" = "opt-out" ]; then
  optOut "$2"
else
  echo "Invalid command"
fi