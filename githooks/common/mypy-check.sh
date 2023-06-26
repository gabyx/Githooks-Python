#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2015


DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$DIR/log.sh"
. "$DIR/version.sh"
. "$DIR/regex-python.sh"

# Assert that 'mypy' (`=$1`) has version `[$2, $3)`.
function assertMyPyVersion() {
    local expectedVersionMin="$1"
    local expectedVersionMax="$2"
    local exe="${3:-mypy}"

    command -v mypy &>/dev/null ||
        die "Tool 'mypy' is not installed."

    local version
    version=$("$exe" --version 2>/dev/null | head -1 | sed -E "s@.*([0-9]+\.[0-9]+\.[0-9]+).*@\1@")

    versionCompare "$version" ">=" "$expectedVersionMin" &&
        versionCompare "$version" "<" "$expectedVersionMax" ||
        {
            "$exe" --version || true
            die "Version of 'mypy' is '$version' but should be '[$expectedVersionMin, $expectedVersionMax)'."
        }

    printInfo "Version: mypy '$version'."

    return 0
}
