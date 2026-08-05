#!/usr/bin/env bash

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temporary="$(mktemp -d)"
trap 'rm -rf "$temporary"' EXIT

version="$("$root/bin/latest-stable")"
[ -n "$version" ]
"$root/bin/list-all" | tr ' ' '\n' | grep -Fx "$version" >/dev/null

ASDF_INSTALL_VERSION="$version" \
	ASDF_DOWNLOAD_PATH="$temporary/download" \
	"$root/bin/download"

ASDF_INSTALL_TYPE="version" \
	ASDF_INSTALL_VERSION="$version" \
	ASDF_DOWNLOAD_PATH="$temporary/download" \
	ASDF_INSTALL_PATH="$temporary/install" \
	"$root/bin/install"

[ "$("$temporary/install/bin/outagedeck" --version)" = "$version" ]

printf 'asdf-outagedeck %s test passed\n' "$version"
