#!/usr/bin/env bash

# e - script sotsp on error
# u - errot if undefined variable
# o pipefail - script fails if one of piped commands fails
# x - output each line (DEBUG)
set -euo pipefail

source "$(dirname "$0")/shunit2/shunit2"
