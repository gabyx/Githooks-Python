#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
ROOT_DIR="$DIR/../../.."
. "$ROOT_DIR/githooks/common/export-staged.sh"
. "$ROOT_DIR/githooks/common/parallel.sh"
. "$ROOT_DIR/githooks/common/black-format.sh"
. "$ROOT_DIR/githooks/common/yapf-format.sh"
. "$ROOT_DIR/githooks/common/isort-format.sh"
. "$ROOT_DIR/githooks/common/stage-files.sh"
. "$ROOT_DIR/githooks/common/log.sh"

assertStagedFiles || die "Could not assert staged files."

printHeader "Running hook: Python format ..."

if [ "${GITHOOKS_PYTHON_FORMAT_USE_YAPF:-}" = "1" ]; then
    tool="yapf"
    func="formatPythonFileYapf"
    assertYapfVersion "0.31.0" "1.0.0" "yapf"
else
    tool="black"
    func="formatPythonFileBlack"
    assertBlackVersion "22.1.0" "24.0.0" "black"
fi

regex=$(getGeneralPythonFileFormatRegex) || die "Could not get python file regex."
parallelForFiles "$func" \
    "$STAGED_FILES" \
    "$regex" \
    "false" \
    "$tool" || die "Python format failed."

assertISortVersion "5.12.0" "6.0.0" "isort"
parallelForFiles "formatIncludesPythonFileISort" \
    "$STAGED_FILES" \
    "$regex" \
    "false" \
    "isort" || die "Python format includes failed."

stageFiles "$PARALLEL_EXECUTED_FILES" ||
    printError "Could not stage formatted files."

stageFiles "$PARALLEL_EXECUTED_FILES" ||
    printError "Could not stage formatted files."
