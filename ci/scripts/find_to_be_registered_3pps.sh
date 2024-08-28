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

ROOT_DIR="$SCRIPT_DIR/../.."

DEPENDENCIES_FILE="$1"

mkdir -p $ROOT_DIR/temp

yq '.dependencies[] | select(.bazaar.register == "yes" ) | .ID' $DEPENDENCIES_FILE > $ROOT_DIR/temp/to_be_registered_3pps.txt