#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2015


DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$DIR/log.sh"
. "$DIR/version.sh"
. "$DIR/regex-python.sh"

# Assert that 'flake8' (`=$1`) has version `[$2, $3)`.
function assertFlake8Version() {
    local expectedVersionMin="$1"
    local expectedVersionMax="$2"
    local exe="${3:-flake8}"

    command -v flake8 &>/dev/null ||
        die "Tool 'flake8' is not installed."

    local version
    version=$("$exe" --version 2>/dev/null | head -1 | sed -E "s@([0-9]+\.[0-9]+\.[0-9]+).*@\1@")

    versionCompare "$version" ">=" "$expectedVersionMin" &&
        versionCompare "$version" "<" "$expectedVersionMax" ||
        {
            "$exe" --version || true
            die "Version of 'flake8' is '$version' but should be '[$expectedVersionMin, $expectedVersionMax)'."
        }

    printInfo "Version: isort '$version'."

    return 0
}

# Check a python file inplace.
function checkPythonFile() {
    local flake8Exe="$1"
    local file="$2"

    printInfo " - ✔️ Checking file: '$file'"
    # Switching to directory of file for makeing flake8
    # searching upward for any .flake8 file.
    local dir filename
    dir=$(dirname "$file")
    filename=$(basename "$file")
    (cd "$dir" && "$flake8Exe" "$filename") 1>&2 ||
        {
            printError "'$flake8Exe' failed for: '$file'"
            return 1
        }

    return 0
}
