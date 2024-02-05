#!/bin/sh
# Path: srs_setup.sh

echo "Downloading srs resources"
echo "Downloading g1 point. This could take upto 5 minutes"
wget https://srs-mainnet.s3.amazonaws.com/kzg/g1.point --output-document=./resources/g1.point
echo "Downloading g2 point. This could take upto 10 minutes"
wget https://srs-mainnet.s3.amazonaws.com/kzg/g2.point --output-document=./resources/g2.point

echo "validating hashes of g1 and g2 points This could take upto 5 minutes"
cd resources && sha256sum -c srssha256sums.txt