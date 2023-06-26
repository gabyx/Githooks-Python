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

dir="${1:-}"

[ -d "$dir" ] || die "Directory '$dir' does not exist."
read -r -p "Shall we really format all files? (No, yes, dry run) [N|y|d]: " what

dryRun="false"

if [ "$what" = "d" ]; then
    what="y"
    dryRun="true"
fi

if [ "$dryRun" = "true" ]; then
    printInfo "Dry-run formatting python files in dir '$dir'."
else
    printInfo "Formatting python files in dir '$dir'."
fi

if [ "${GITHOOKS_PYTHON_FORMAT_USE_YAPF:-}" = "1" ]; then
    assertYapfVersion "0.31.0" "1.0.0" "yapf"

    if [ "$what" = "y" ]; then
        if [ "$dryRun" = "true" ]; then
            yapf -d "$dir" || die "Formatting in '$dir' with 'yapf' failed."
        else
            yapf -i "$dir" || die "Formatting in '$dir' with 'yapf' failed."
        fi
    fi

else
    assertBlackVersion "22.1.0" "24.0.0" "black"

    if [ "$what" = "y" ]; then
        if [ "$dryRun" = "true" ]; then
            black --diff "$dir" || die "Formatting in '$dir' with 'black' failed."
        else
            black "$dir" || die "Formatting in '$dir' 'black' failed."
        fi
    fi

fi

assertISortVersion "5.12.0" "6.0.0" "isort"
if [ "$what" = "y" ]; then
    if [ "$dryRun" = "true" ]; then
        isort --check "$dir" || die "Formatting in '$dir' with 'isort' failed."
    else
        isort "$dir" || die "Formatting in '$dir' with 'isort' failed."
    fi
fi
