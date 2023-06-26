#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

set -e
set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$DIR/../common/log.sh"
. "$DIR/../common/parallel.sh"
. "$DIR/../common/flake8-check.sh"

dir="${1:-}"

[ -d "$dir" ] || die "Directory '$dir' does not exist."

printInfo "Checking python files in dir '$dir'."

assertFlake8Version "4.0.1" "7.0.0" "flake8"
flake8 "$dir" || die "Checking in '$dir' with 'flake8' failed."
