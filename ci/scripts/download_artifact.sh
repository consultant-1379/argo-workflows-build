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

#!/usr/bin/env bash

set -ex -o pipefail

SCRIPT=$(readlink -f $0)
# Location of parent dir
BASE_DIR=$(dirname $SCRIPT)
REPOROOT=$(dirname $(dirname $BASE_DIR))

PACKAGE_URL="$1"
OUTPUT_DIR="$2"


if [[ -z $ARM_API_TOKEN ]]
then 
    echo "ARM_API_TOKEN is not set"
    exit 1
fi

mkdir -p ${OUTPUT_DIR}
cd ${OUTPUT_DIR}
curl -O -H "X-JFrog-Art-Api: ${ARM_API_TOKEN}" "${PACKAGE_URL}"
status=$?
if [ $status -ne 0 ]; then
    echo "Failed to download stdout-redirect package"
    exit $status
fi;
tar xvf *.tar
rm -f *.tar
cd $OLDPWD