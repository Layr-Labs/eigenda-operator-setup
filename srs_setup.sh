#!/bin/sh
# Path: srs_setup.sh

wget https://srs-mainnet.s3.amazonaws.com/kzg/g1.point --output-document=./resources/g1.point
wget https://srs-mainnet.s3.amazonaws.com/kzg/g2.point --output-document=./resources/g2.point

sha256sum -c ./resources/srssha256sums.txt