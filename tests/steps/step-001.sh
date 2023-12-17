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
installHook "$GH_TEST_REPO/githooks/pre-commit" -and -path '*/1-format/.format-python.sh' ||
    die "Install hook failed"

yapf --version || die "Yapf not available."
black --version || die "Black not available."

function setupFiles() {
    echo "a = [1 ,   2 , 3]" >"A1.py"
    echo "a = [1 ,   2 , 3]" >"Tiltfile"
}

setupFiles ||
    die "Could not make test sources."

git add . || die "Could not add files."

out=$(git commit -a -m "Formatting files." 2>&1)
# shellcheck disable=SC2181
if [ $? -ne 0 ] ||
    ! echo "$out" | grep -qi "formatting.*A1\.py" ||
    ! echo "$out" | grep -qi "formatting.*Tiltfile"; then
    echo "Expected to have formatted all files. $out"
    exit 1
fi

if ! git diff --quiet; then
    echo "Expected repository to be not dirty, formatted files are checked in."
    git status
    exit 1
fi

setupFiles || die "Could not setup files again."

if [ "$(git status --short | grep -c 'A.*')" != "6" ]; then
    echo "Expected repository to be dirty, formatting did not work."
    git status
fi
