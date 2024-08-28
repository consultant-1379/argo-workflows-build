#!/usr/bin/env bash
#
# COPYRIGHT Ericsson 2022
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

set -ux -o pipefail

# Absolute filepath to this script
case "$(uname -s)" in
Darwin*) SCRIPT=$(greadlink -f $0) ;;
*) SCRIPT=$(readlink -f $0) ;;
esac

# Location of parent dir
BASE_DIR=$(dirname $SCRIPT)
REPOROOT=$(dirname $(dirname $BASE_DIR))

BOB_DIR=$REPOROOT/.bob

CURRENT_STDOUT_VERSION="$1"

if [ -z "$ARM_API_TOKEN" ]; then
    echo "ARM_API_TOKEN is not set"
    exit 1
fi

if [ -z "$CI_USER"  ]; then
    echo "CI_USER is not set"
    exit 1
fi

STDOUT_DETAILS_FILE=$BOB_DIR/stdout-pra-details.json

curl -s -u"$CI_USER:$ARM_API_TOKEN" -X POST https://arm.seli.gic.ericsson.se/artifactory/api/search/aql -H "content-type:text/plain" -d 'items.find({ "repo": {"$eq":"proj-adp-log-release-local"},"path":{"$match": "com/ericsson/bss/adp/log/stdout-redirect/*.*.*"}}).sort({"$desc": ["created"]}).limit(1)' > $STDOUT_DETAILS_FILE
aqlStatus=$?

if [ $aqlStatus -ne 0 ]; then
    echo "Failed to get latest Stdout version"
fi

if [ -f $STDOUT_DETAILS_FILE ]; then
    STDOUT_PRA_VERSION=$(cat $STDOUT_DETAILS_FILE | jq -r '.results[0].path' | sed 's#com/ericsson/bss/adp/log/stdout-redirect/##')
    echo $STDOUT_PRA_VERSION | tee $BOB_DIR/var.latest-stdout-pra-version
    if [ "$CURRENT_STDOUT_VERSION" != "$STDOUT_PRA_VERSION" ]; then
        echo "Failed Stdout-redirect check"
        printf "Newer version available for stdout-redirect.\nLatest PRA version: $STDOUT_PRA_VERSION\nVersion used in codebase: $CURRENT_STDOUT_VERSION" > $BOB_DIR/var.stdout-redirect-version-mismatch
    fi
else
    echo "Failed to get STDOUT PRA version"
fi