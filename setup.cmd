@echo off
rem MarketAI Connector setup: add, change or remove the bots in this folder.
rem
rem   setup.cmd       (in PowerShell: .\setup.cmd)
rem
rem It runs inside the connector image, on this folder, so it needs nothing but Docker.
rem It writes only your own files (bot-*.env, compose.override.yml).
setlocal
cd /d "%~dp0"

set "IMAGE=ghcr.io/sergimes/marketai-connector:latest"
for /f "tokens=2 delims==" %%v in ('findstr /b "CONNECTOR_VERSION=" .env 2^>nul') do set "IMAGE=ghcr.io/sergimes/marketai-connector:%%v"

docker pull -q %IMAGE% >nul
docker run --rm -it -v "%cd%:/work" %IMAGE% setup %*
