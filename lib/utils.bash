#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/outagedeck/cli"
TOOL_NAME="outagedeck"

fail() {
	printf 'asdf-%s: %s\n' "$TOOL_NAME" "$*" >&2
	exit 1
}

curl_opts=(-fsSL)
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts+=(--header "Authorization: Bearer $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n |
		awk '{print $2}'
}

list_all_versions() {
	git ls-remote --tags --refs "$GH_REPO" |
		awk '{sub("refs/tags/", "", $2); sub(/^v/, "", $2); print $2}'
}

release_platform() {
	case "$(uname -s)" in
	Darwin) printf 'darwin\n' ;;
	Linux) printf 'linux\n' ;;
	*) fail "unsupported operating system: $(uname -s)" ;;
	esac
}

release_arch() {
	case "$(uname -m)" in
	x86_64 | amd64) printf 'amd64\n' ;;
	arm64 | aarch64) printf 'arm64\n' ;;
	*) fail "unsupported architecture: $(uname -m)" ;;
	esac
}

sha256_file() {
	if command -v sha256sum >/dev/null 2>&1; then
		sha256sum "$1" | awk '{print $1}'
	elif command -v shasum >/dev/null 2>&1; then
		shasum -a 256 "$1" | awk '{print $1}'
	else
		fail "sha256sum or shasum is required to verify the download"
	fi
}

download_release() {
	local version="$1"
	local destination="$2"
	local platform arch archive base_url checksum_file expected actual

	platform="$(release_platform)"
	arch="$(release_arch)"
	archive="outagedeck_${version}_${platform}_${arch}.tar.gz"
	base_url="$GH_REPO/releases/download/v${version}"
	checksum_file="${destination}.checksums"

	printf '* Downloading %s %s for %s/%s...\n' "$TOOL_NAME" "$version" "$platform" "$arch"
	curl "${curl_opts[@]}" --output "$destination" "$base_url/$archive" ||
		fail "could not download $base_url/$archive"
	curl "${curl_opts[@]}" --output "$checksum_file" "$base_url/checksums.txt" ||
		fail "could not download $base_url/checksums.txt"

	expected="$(awk -v archive="$archive" '$2 == archive || $2 == "dist/" archive {print $1}' "$checksum_file")"
	[ -n "$expected" ] || fail "checksum manifest has no entry for $archive"
	actual="$(sha256_file "$destination")"
	[ "$actual" = "$expected" ] || fail "checksum mismatch for $archive"

	rm -f "$checksum_file"
}
