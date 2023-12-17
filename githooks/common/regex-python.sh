#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2015

# Get the general python file regex.
function getGeneralPythonFileFormatRegex() {
    # shellcheck disable=2028
    echo '.*(\.py|\bTiltfile)$'
}

function getGeneralPythonFileRegex() {
    echo '.*\.py'
}
