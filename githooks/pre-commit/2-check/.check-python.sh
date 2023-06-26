#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2015


DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
ROOT_DIR="$DIR/../../.."
. "$ROOT_DIR/githooks/common/export-staged.sh"
. "$ROOT_DIR/githooks/common/parallel.sh"
. "$ROOT_DIR/githooks/common/flake8-check.sh"
. "$ROOT_DIR/githooks/common/stage-files.sh"
. "$ROOT_DIR/githooks/common/log.sh"

assertStagedFiles || die "Could not assert staged files."

printHeader "Running hook: Python flake8 ..."

assertFlake8Version "4.0.1" "7.0.0" "flake8"

regex=$(getGeneralPythonFileRegex) || die "Could not get python file regex."
parallelForFiles checkPythonFile \
    "$STAGED_FILES" \
    "$regex" \
    "false" \
    "flake8" || die "Python check failed."
