#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2015
# Test:
#   Run python-format hook on staged files

set -u

. "$GH_TEST_REPO/tests/general.sh"

function finish() {
    cleanRepos
}
trap finish EXIT

initGit || die "Init failed"
installHook "$GH_TEST_REPO/githooks/pre-commit" -and -path '*/2-check/.check-python.sh' ||
    die "Install hook failed"

flake8 --version || die "Flake8 not available."

function setupFiles() {
    echo "a = [1 ,   2 , 3]" >"A1.py"
    echo "a = [1 ,   2 , 3]" >"Tiltfile"
}

setupFiles ||
    die "Could not make test sources."

git add . || die "Could not add files."

out=$(git commit -a -m "Checking files." 2>&1)
# shellcheck disable=SC2181
if [ $? -eq 0 ] ||
    ! echo "$out" | grep -qi "checking.*A1\.py" ||
    echo "$out" | grep -qi "checking.*Tiltfile" ||
    ! echo "$out" | grep -qi "E203"; then
    echo "Expected to have checked all files. $out"
    exit 1
fi
