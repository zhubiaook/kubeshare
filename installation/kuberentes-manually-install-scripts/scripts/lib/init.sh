#!/bin/bash

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

set -o errexit
set -o nounset
set -o pipefail

source "${SCRIPT_ROOT}/lib/log.sh"
source "${SCRIPT_ROOT}/lib/killprocess.sh"
source "${SCRIPT_ROOT}/lib/strings.sh"
