#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

set -e
set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$DIR/../common/log.sh"
. "$DIR/../common/parallel.sh"
. "$DIR/../common/mypy-check.sh"

dir="${1:-}"

[ -d "$dir" ] || die "Directory '$dir' does not exist."

printInfo "Checking python files in dir '$dir'."

assertMyPyVersion "1.0.0" "2.0.0" "mypy"
mypy "$dir" || die "Checking in '$dir' with 'mypy' failed."
