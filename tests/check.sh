#!/bin/sh
set -eu

ROOT=$(CDPATH='' cd "$(dirname "$0")/.." && pwd)
TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT HUP INT TERM

mkdir -p "$TEST_HOME/config"
ln -s "$ROOT" "$TEST_HOME/config/nvim"

NVIM_CONFIG_TEST=1 \
	XDG_CONFIG_HOME="$TEST_HOME/config" \
	XDG_DATA_HOME="$TEST_HOME/data" \
	XDG_STATE_HOME="$TEST_HOME/state" \
	XDG_CACHE_HOME="$TEST_HOME/cache" \
	nvim --headless -i NONE -n +qa

nvim --headless -u NONE -i NONE -n -l "$ROOT/tests/check.lua"
