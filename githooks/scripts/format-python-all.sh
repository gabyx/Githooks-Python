#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

set -e
set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$DIR/../common/log.sh"
. "$DIR/../common/parallel.sh"
. "$DIR/../common/yapf-format.sh"
. "$DIR/../common/black-format.sh"
. "$DIR/../common/isort-format.sh"

dryRun="true"
dir=""
excludeRegex=""
regex=$(getGeneralPythonFileFormatRegex)

function help() {
    printError "Usage:" \
        "  [--force]                      : Force the format." \
        "  [--exclude-regex <regex> ]     : Exclude file with this regex." \
        "  [--regex-pattern <pattern>]     : Regex pattern to include files." \
        "   --dir <path>                  : In which directory to format files."
}

function parseArgs() {
    local prev=""

    for p in "$@"; do
        if [ "$p" = "--force" ]; then
            dryRun="false"
        elif [ "$p" = "--help" ]; then
            help
            return 1
        elif [ "$p" = "--dir" ]; then
            true
        elif [ "$prev" = "--dir" ]; then
            dir="$p"
        elif [ "$p" = "--exclude" ]; then
            true
        elif [ "$prev" = "--exclude" ]; then
            excludeRegex="$p"
        elif [ "$p" = "--include" ]; then
            true
        elif [ "$prev" = "--include" ]; then
            regex="$p"
        else
            printError "! Unknown argument \`$p\`"
            help
            return 1
        fi

        prev="$p"
    done
}

parseArgs "$@"

if [ "$dryRun" = "true" ]; then
    printInfo "Dry-run formatting python files in dir '$dir'."
else
    printInfo "Formatting python files in dir '$dir'."
fi

if [ "${GITHOOKS_PYTHON_FORMAT_USE_YAPF:-}" = "1" ]; then
    tool="yapf"
    func="formatPythonFileYapf"
    assertYapfVersion "0.31.0" "1.0.0" "yapf"
else
    tool="black"
    func="formatPythonFileBlack"
    assertBlackVersion "22.1.0" "24.0.0" "black"
fi

parallelForDir "$func" \
    "$dir" \
    "$regex" \
    "$excludeRegex" \
    "$dryRun" \
    "$tool" || die "Python format failed."

assertISortVersion "5.12.0" "6.0.0" "isort"
parallelForDir "formatIncludesPythonFileISort" \
    "$dir" \
    "$regex" \
    "$excludeRegex" \
    "$dryRun" \
    "isort" || die "Python format includes failed."
