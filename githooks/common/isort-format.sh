#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2015


DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$DIR/log.sh"
. "$DIR/version.sh"
. "$DIR/regex-python.sh"

# Assert that 'isort' (`=$1`) has version `[$2, $3)`.
function assertISortVersion() {
    local expectedVersionMin="$1"
    local expectedVersionMax="$2"
    local exe="${3:-isort}"

    command -v isort &>/dev/null ||
        die "Tool 'isort' is not installed."

    local version
    version=$("$exe" --version-number 2>/dev/null | head -1 | sed -E "s@([0-9]+\.[0-9]+\.[0-9]+).*@\1@")

    versionCompare "$version" ">=" "$expectedVersionMin" &&
        versionCompare "$version" "<" "$expectedVersionMax" ||
        {
            "$exe" --version-number || true
            die "Version of 'isort' is '$version' but should be '[$expectedVersionMin, $expectedVersionMax)'."
        }

    printInfo "Version: isort '$version'."

    return 0
}

# Format includes.
function formatIncludesPythonFile() {
    local isortExe="$1"
    local file="$2"

    printInfo " - ✔️ Formatting includes in file: '$file'"
    "$isortExe" "$file" 1>&2 ||
        {
            printError "'$isortExe' failed for: '$file'"
            return 1
        }

    return 0
}
