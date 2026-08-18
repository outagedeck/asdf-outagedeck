# asdf-outagedeck

[![Build](https://github.com/outagedeck/asdf-outagedeck/actions/workflows/test.yml/badge.svg)](https://github.com/outagedeck/asdf-outagedeck/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

An [asdf](https://asdf-vm.com/) plugin for installing the
[OutageDeck CLI](https://outagedeck.com?utm_source=github&utm_medium=repository&utm_campaign=asdf_plugin),
which checks status published through official cloud and SaaS vendor feeds.

## Install

```bash
asdf plugin add outagedeck https://github.com/outagedeck/asdf-outagedeck.git
asdf install outagedeck latest
asdf set -u outagedeck latest
```

Then check the providers your workflow depends on:

```bash
outagedeck status aws cloudflare github openai
outagedeck status --json --fail-on=outage aws github openai
```

The plugin supports the macOS and Linux release archives published for AMD64
and ARM64. Downloads are verified against the release checksum manifest before
installation.

## License

MIT
