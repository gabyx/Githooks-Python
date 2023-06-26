#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2015


DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$DIR/log.sh"
. "$DIR/version.sh"
. "$DIR/regex-python.sh"

# Assert that 'black' (`=$1`) has version `[$2, $3)`.
function assertBlackVersion() {
    local expectedVersionMin="$1"
    local expectedVersionMax="$2"
    local exe="${3:-black}"

    command -v "$exe" &>/dev/null ||
        die "Tool '$exe' is not installed."

    local version
    version=$("$exe" --version 2>/dev/null | head -1 | sed -E "s@.* ([0-9]+\.[0-9]+\.[0-9]+).*@\1@")

    versionCompare "$version" ">=" "$expectedVersionMin" &&
        versionCompare "$version" "<" "$expectedVersionMax" ||
        {
            "$exe" --version || true
            die "Version of '$exe' is '$version' but should be '[$expectedVersionMin, $expectedVersionMax)'."
        }

    printInfo "Version: black '$version'."

    return 0
}

# Format a python file inplace.
function formatPythonFileBlack() {
    local blackExe="$1"
    local file="$2"

    printInfo " - ✍ Formatting file: '$file'"
    "$blackExe" "$file" 1>&2 ||
        {
            printError "'$blackExe' failed for: '$file'"
            return 1
        }

    return 0
}
