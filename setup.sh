#!/bin/sh
# MarketAI Connector setup: add, change or remove the bots in this folder.
#
#   ./setup.sh
#
# It runs inside the connector image, as you, on this folder, so it needs nothing but
# Docker. It writes only your own files (bot-*.env, compose.override.yml).
set -e
cd "$(dirname "$0")"

version=$(sed -n 's/^CONNECTOR_VERSION=//p' .env 2>/dev/null | tr -d '\r' | tail -n 1)
image="ghcr.io/sergimes/marketai-connector:${version:-latest}"

docker pull -q "$image" > /dev/null
exec docker run --rm -it --user "$(id -u):$(id -g)" -v "$(pwd):/work" "$image" setup "$@"
