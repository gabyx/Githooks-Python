<img src="https://raw.githubusercontent.com/gabyx/githooks/main/docs/githooks-logo.svg" style="margin-left: 20pt" align="right">

# Githooks for Python

This repository contains shared repository Git hooks for shell scripts in
`githooks/*` to be used with the
[Githooks Manager](https://github.com/gabyx/Githooks).

The following is included:

- Hook to format python files with `black` (or `yapf`) (pre-commit).
- Hook to check python files with `flake8` (pre-commit).
- Scripts for linting/formatting including running `mypy`

<details>
<summary><b>Table of Content (click to expand)</b></summary>

<!-- TOC -->

- [Githooks for Python](#githooks-for-python)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Hook: `pre-commit/1-format/format-python.yaml`](#hook-pre-commit1-formatformat-pythonyaml)
  - [Hook: `pre-commit/2-check/check-python.yaml`](#hook-pre-commit2-checkcheck-pythonyaml)
  - [Scripts](#scripts)
  - [Testing](#testing)

</details>

## Requirements

Run them
[containerized](https://github.com/gabyx/Githooks#running-hooks-in-containers)
where only `docker` is required.

If you want to run them non-containerized, make the following installed on your
system:

- Python requirements in [`requirements.txt`](configs/requirements.txt)
- `bash`
- GNU `grep`
- GNU `sed`
- GNU `find`
- GNU `xargs`
- GNU `parallel` _[optional]_

This works with Windows setups too.

## Installation

The hooks can be used by simply using this repository as a shared hook
repository inside python projects.
[See further documentation](https://github.com/gabyx/githooks#shared-hook-repositories).

You should configure the shared hook repository in your project to use this
repos `main` branch by using the following `.githooks/.shared.yaml` :

```yaml
version: 1
urls:
  - https://github.com/gabyx/githooks-python.git@main`.
```

## Hook: `pre-commit/1-format/format-python.yaml`

Formats all staged files with `black`.

For temporary using `yapf` use `.githooks/.envs.yaml` :

```yaml
envs:
  githooks-python:
    - GITHOOKS_PYTHON_FORMAT_USE_YAPF=1
```

## Hook: `pre-commit/2-check/check-python.yaml`

Lints all files staged files with `flake8`.

## Scripts

The following scripts are provided:

- [`format-python-all.sh`](githooks/scripts/format-python-all.sh) : Script to
  format all python files in a directory recursively. See documentation.

- [`check-python-all.sh`](githooks/scripts/format-python-all.sh) : Script to
  check all python files in a directory recursively. See documentation.

- [`check-python-static-all.sh`](githooks/scripts/format-python-all.sh) : Script
  to check all python files statically with `mypy` in a directory recursively.
  See documentation.

They can be used in scripts by doing the following trick inside a repo which
uses this hook:

```shell
shellHooks=$(git hooks shared root ns:githooks-python)
"$shellHooks/githooks/scripts/<script-name>.sh"
```

## Testing

The containerized tests in `tests/*` are executed by

```bash
tests/test.sh
```

or only special tests steps by

```bash
tests/test.sh --seq 001..010
```

For showing the output also in case of success use:

```bash
tests/test.sh --show-output [other-args]
```
