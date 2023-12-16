#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

set -e
set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$DIR/../common/log.sh"
. "$DIR/../common/parallel.sh"
. "$DIR/../common/mypy-check.sh"

dir=""

function help() {
    printError "Usage:" \
        "   --dir <path>  : In which directory to check files."
}

function parseArgs() {
    local prev=""

    for p in "$@"; do
        if [ "$p" = "--help" ]; then
            help
            return 1
        elif [ "$p" = "--dir" ]; then
            true
        elif [ "$prev" = "--dir" ]; then
            dir="$p"
        else
            printError "! Unknown argument \`$p\`"
            help
            return 1
        fi

        prev="$p"
    done
}

parseArgs "$@"

[ -d "$dir" ] || die "Directory '$dir' does not exist."

printInfo "Checking python files in dir '$dir'."

assertMyPyVersion "1.0.0" "2.0.0" "mypy"
mypy "$dir" || die "Checking in '$dir' with 'mypy' failed."
