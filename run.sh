#!/bin/sh
# Path: run.sh

. ./.env

# In both opt-in and opt-out, We have to explicitly set the password again here because
# when docker run loads the `.env` file, it keeps the quotes around the password
# which causes the password to be incorrect.
# To test that try running `docker run --rm --env-file .env busybox /bin/sh -c 'echo $NODE_ECDSA_KEY_PASSWORD'`
# This will output password with single quote. Not sure why this happens.
# Function to read Docker secrets
read_secret() {
  secret_name=$1
  secret_path="/run/secrets/$secret_name"
  if [ -f "$secret_path" ]; then
    cat "$secret_path"
  else
    echo "Error: Secret $secret_name not found."
    exit 1
  fi
}

optIn() {
  socket="$NODE_HOSTNAME":"${NODE_DISPERSAL_PORT}"\;"${NODE_RETRIEVAL_PORT}"
  echo "using socket: $socket"
  docker run --env-file .env \
  --rm \
  --volume "${NODE_ECDSA_KEY_FILE_HOST}":/app/operator_keys/ecdsa_key.json \
  --volume "${NODE_BLS_KEY_FILE_HOST}":/app/operator_keys/bls_key.json \
  --volume "${NODE_LOG_PATH_HOST}":/app/logs:rw \
  --volume "ecdsa_key_password:/run/secrets/ecdsa_key_password:ro" \
  --volume "bls_key_password:/run/secrets/bls_key_password:ro" \
  ghcr.io/layr-labs/eigenda/opr-nodeplugin:release-0.2.1 \
  --operation opt-in \
  --socket "$socket"
}

optOut() {
  socket="$NODE_HOSTNAME":"${NODE_DISPERSAL_PORT}"\;"${NODE_RETRIEVAL_PORT}"
  docker run --env-file .env \
    --rm \
    --volume "${NODE_ECDSA_KEY_FILE_HOST}":/app/operator_keys/ecdsa_key.json \
    --volume "${NODE_BLS_KEY_FILE_HOST}":/app/operator_keys/bls_key.json \
    --volume "${NODE_LOG_PATH_HOST}":/app/logs:rw \
    --volume "ecdsa_key_password:/run/secrets/ecdsa_key_password:ro" \
    --volume "bls_key_password:/run/secrets/bls_key_password:ro" \
    ghcr.io/layr-labs/eigenda/opr-nodeplugin:release-0.2.1 \
    --operation opt-out \
    --socket "$socket"
}

if [ "$1" = "opt-in" ]; then
  optIn
elif [ "$1" = "opt-out" ]; then
  optOut
else
  echo "Invalid command"
fi
