#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT

export NVIM_APPNAME=nvim-native
export XDG_CONFIG_HOME="$tmp/config"
export XDG_DATA_HOME="$tmp/data"
export XDG_STATE_HOME="$tmp/state"
export XDG_CACHE_HOME="$tmp/cache"
mkdir -p "$XDG_CONFIG_HOME"
ln -s "$root" "$XDG_CONFIG_HOME/nvim-native"

# Verify that installed third-party packages cannot leak into this config.
plugin="$XDG_DATA_HOME/nvim-native/site/pack/test/start/dummy/plugin"
mkdir -p "$plugin"
printf '%s\n' 'error("Third-party package was loaded")' > "$plugin/dummy.lua"

cd -- "$root"
nvim --headless -i NONE -c "lua dofile('tests/smoke.lua')"
