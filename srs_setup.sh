#!/bin/sh
# Path: srs_setup.sh

. ./.env

DOWNLOADED_FILE=false
echo "Downloading srs resources"
if ! [ -f $NODE_G1_PATH_HOST ]; then
  echo "g1.point does not exist."
  echo "Downloading g1 point. This could take upto 5 minutes"
  wget https://srs-mainnet.s3.amazonaws.com/kzg/g1.point --output-document=$NODE_G1_PATH_HOST
  DOWNLOADED_FILE=true
fi

if ! [ -f $NODE_G2_PATH_HOST ]; then
  echo "g2.point.powerOf2 does not exist."
  echo "Downloading g2 point powerOf2. This will take few seconds"
  wget https://srs-mainnet.s3.amazonaws.com/kzg/g2.point.powerOf2 --output-document=$NODE_G2_PATH_HOST
  DOWNLOADED_FILE=true
fi

# Any time we download the file, validate hashes
if [ "$DOWNLOADED_FILE" = true ]; then
  echo "validating hashes of g1 and g2 points This could take upto 5 minutes"

  CHECKSUM_FILE="../resources/srssha256sums.txt"

  G1_CHECKSUM_EXPECTED=$(grep 'g1.point$' "$CHECKSUM_FILE" | awk '{print $1}')
  G2_CHECKSUM_EXPECTED=$(grep 'g2.point.powerOf2$' "$CHECKSUM_FILE" | awk '{print $1}')

  G1_CHECKSUM_ACTUAL=$(sha256sum "$NODE_G1_PATH_HOST" | awk '{print $1}')
  G2_CHECKSUM_ACTUAL=$(sha256sum "$NODE_G2_PATH_HOST" | awk '{print $1}')

  if [ "$G1_CHECKSUM_EXPECTED" = "$G1_CHECKSUM_ACTUAL" ] && [ "$G2_CHECKSUM_EXPECTED" = "$G2_CHECKSUM_ACTUAL" ]; then
    echo "Checksums match. Verification successful."
  else
    echo "Error: Checksums do not match. Exiting."
    exit 1
  fi
fi
