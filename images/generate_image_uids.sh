#!/usr/bin/env bash

set -eux -o pipefail

OUTPUT_FILE="images/uid.txt"

# This script is used to generate a unique UID for Argo Images

generate_uid(){
local cntr="$1"
local outputFile="$2"
h=$( sha256sum <<< "${cntr}" | cut -f1 -d ' ' ) 
printf -- '%s : %d\n' "${cntr}" "$( bc -q <<< "scale=0;obase=10;ibase=16;(${h^^}%30D41)+186A0" )" >> "${outputFile}"
}

images=(
    eric-aiml-pipeline-argoexec
    eric-aiml-pipeline-argocli
    eric-aiml-pipeline-workflow-controller
    eric-aiml-pipeline-init
)

[ -f "${OUTPUT_FILE}" ] && rm "${OUTPUT_FILE}" || true

for image in "${images[@]}"; do
    generate_uid "${image}" "${OUTPUT_FILE}"
done

