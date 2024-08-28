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
set -eux -o pipefail

# Absolute filepath to this script
case "$(uname -s)" in
Darwin*) SCRIPT=$(greadlink -f $0) ;;
*) SCRIPT=$(readlink -f $0) ;;
esac

# Location of parent dir
BASE_DIR=$(dirname $SCRIPT)
REPOROOT=$(dirname $(dirname $BASE_DIR))

# Argo workflows fork in gerrit
ARGO_WORKFLOWS_REPO_URL=ssh://gerrit-gamma.gic.ericsson.se:29418/MXE/mlops-3pps/argo-workflows 

# Function usage() shows how to invoke this script
usage() {
  echo "usage: $0 -v RELEASE_TAG"
  exit 1
}

# parse input args
while [ $# -gt 0 ]; do
  case "$1" in
    --version|-v)
      RELEASE_TAG="${2}"
      shift 2
      ;;
    --clone-to)
      ARGO_WORKFLOWS_WORKSPACE="${2}"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

# Function cleanup() cleans all temporary directories if they are available 
cleanup() {
    TEMP_DIRS=(
        "${ARGO_WORKFLOWS_WORKSPACE}"
    )

    for temp_dir in "${TEMP_DIRS[@]}"
    do 
      if [[ -d "${temp_dir}" ]]
      then
        rm -rf "${temp_dir}"
      fi 
    done 
}

# clean workspace if it already exists
cleanup

# clone Release tag version to argo workspace dir
git clone -b "${RELEASE_TAG}" "${ARGO_WORKFLOWS_REPO_URL}" "${ARGO_WORKFLOWS_WORKSPACE}"

