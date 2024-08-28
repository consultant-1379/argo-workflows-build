#!/usr/bin/env bash
#
# COPYRIGHT Ericsson 2023
#
#
#
# The copyright to the computer program(s) herein is the property of
#
# Ericsson Inc. The programs may be used and/or copied only with written
#
# permission from Ericsson Inc. or in accordance with the terms and
#
# conditions stipulated in the agreement/contract under which the
#
# program(s) have been supplied.
#


set -eu -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$( cd "$SCRIPT_DIR/../.." && pwd )"
OUTPUT_FILE="$ROOT_DIR/scas_refresh_token.sh"
TEMP_DIR="$ROOT_DIR/temp"

# Get the token from the SCAS

if [ -z "$SCAS_USERNAME" ]; then
  echo "SCAS_USERNAME is not set"
  exit 1
fi

if [ -z "$SCAS_PASSWORD" ]; then
  echo "SCAS_PASSWORD is not set"
  exit 1
fi

if [ -f $OUTPUT_FILE ]
then
  rm $OUTPUT_FILE
fi

OIDC_BASE_URL='https://scas.internal.ericsson.com/auth/realms/SCA/protocol/openid-connect'

mkdir -p $TEMP_DIR

curl -X POST \
  -d "grant_type=password" \
  -d "scope=offline_access" \
  -d "client_id=scas-ext-client-direct" \
  -d "username=$SCAS_USERNAME" \
  --data-urlencode "password=$SCAS_PASSWORD" \
  $OIDC_BASE_URL/token > $TEMP_DIR/token.json

SCAS_REFRESH_TOKEN=$(cat $TEMP_DIR/token.json | jq -r '.refresh_token')
SCAS_ACCESS_TOKEN=$(cat $TEMP_DIR/token.json | jq -r '.access_token')

if [ -z "$SCAS_REFRESH_TOKEN" ]; then
  echo "Failed to get refresh token"
  exit 1
fi

if [ -z "$SCAS_ACCESS_TOKEN" ]; then
  echo "Failed to get access token"
  exit 1
fi

echo > $OUTPUT_FILE
echo "export SCAS_ACCESS_TOKEN=$SCAS_ACCESS_TOKEN" >> $OUTPUT_FILE
echo "export SCAS_REFRESH_TOKEN=$SCAS_REFRESH_TOKEN" >> $OUTPUT_FILE