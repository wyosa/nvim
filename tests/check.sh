#!/bin/sh
set -eu
export NVIM_APPNAME=nvim

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

REAL_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
REAL_LAZY_ROOT="$REAL_DATA_HOME/nvim/lazy"
if [ ! -d "$REAL_LAZY_ROOT/lazy.nvim" ]; then
	echo "lazy.nvim is not installed under $REAL_LAZY_ROOT" >&2
	exit 1
fi

mkdir -p "$TEST_HOME/data/nvim"
cp -R "$REAL_LAZY_ROOT" "$TEST_HOME/data/nvim/lazy"

# shellcheck disable=SC2016
NVIM_CONFIG_TEST=smoke \
	NVIM_SMOKE_SCRIPT="$ROOT/tests/smoke.lua" \
	XDG_CONFIG_HOME="$TEST_HOME/config" \
	XDG_DATA_HOME="$TEST_HOME/data" \
	XDG_STATE_HOME="$TEST_HOME/state" \
	XDG_CACHE_HOME="$TEST_HOME/cache" \
	nvim --headless -i NONE -n -c 'execute "luafile " . fnameescape($NVIM_SMOKE_SCRIPT)' +qa
