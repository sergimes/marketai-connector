@echo off
rem MarketAI Connector setup: add, change or remove the bots in this folder, start or
rem stop them, and see how they are doing.
rem
rem   setup.cmd       (in PowerShell: .\setup.cmd)
rem
rem The questions run inside the connector image, on this folder, so they need nothing
rem but Docker. They write only your own files (bot-*.env, compose.override.yml).
rem Starting and stopping the bots runs here, with docker compose: a container cannot
rem start or stop other containers unless it is given control of Docker, and the setup
rem is not.
setlocal
cd /d "%~dp0"

set "IMAGE=ghcr.io/sergimes/marketai-connector:latest"
for /f "tokens=2 delims==" %%v in ('findstr /b "CONNECTOR_VERSION=" .env 2^>nul') do set "IMAGE=ghcr.io/sergimes/marketai-connector:%%v"

docker pull -q %IMAGE% >nul

set "AGAIN="
:ask
rem What Docker says about the bots, for the setup to show. Nothing else is shared.
docker compose ps -a --format json > .setup-status.json 2>nul || del .setup-status.json 2>nul
if exist .setup-action del .setup-action
docker run --rm -it -v "%cd%:/work" -e SETUP_ACTIONS=1 %IMAGE% setup %AGAIN% %*
set "STATUS=%errorlevel%"
set "ACTION="
if exist .setup-action set /p ACTION=<.setup-action
if exist .setup-status.json del .setup-status.json
if exist .setup-action del .setup-action
if not "%STATUS%"=="0" exit /b %STATUS%

rem The setup asked for one of these, and nothing else is run. Its words are only ever
rem compared, with delayed expansion (!ACTION!), so nothing in them is read as a
rem command; a bot's id must be letters and digits only before it is used.
set "GO="
set "SERVICE="
setlocal EnableDelayedExpansion
if "!ACTION!"=="start" set "GO=start"
if "!ACTION!"=="start-exit" set "GO=start-exit"
if "!ACTION!"=="stop" set "GO=stop"
if "!ACTION:~0,9!"=="logs bot-" (
    set "REST=!ACTION:~9!"
    for %%c in (0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z) do (
        if defined REST set "REST=!REST:%%c=!"
    )
    if not defined REST if not "!ACTION:~9!"=="" (set "GO=logs" & set "SERVICE=!ACTION:~5!")
)
endlocal & set "GO=%GO%" & set "SERVICE=%SERVICE%"

if "%GO%"=="start" goto start
if "%GO%"=="start-exit" goto start
if "%GO%"=="stop" goto stop
if "%GO%"=="logs" goto logs
exit /b 0

rem .setup-pending (changes saved, not applied yet) goes only once Docker applied them.
:start
docker compose up -d --remove-orphans
if errorlevel 1 (echo Docker could not start them: see above.) else (if exist .setup-pending del .setup-pending)
if "%GO%"=="start-exit" exit /b 0
goto back

:stop
rem Apply the changes first: a bot removed here is no longer in the files, and
rem "docker compose stop" alone would leave it running.
docker compose up --no-start --remove-orphans
if errorlevel 1 (echo Docker could not stop them: see above. & goto back)
docker compose stop
if errorlevel 1 (echo Docker could not stop them: see above.) else (if exist .setup-pending del .setup-pending)
goto back

:logs
docker compose logs --tail 40 --no-log-prefix %SERVICE%
goto back

:back
echo.
echo Press any key to go back to the setup.
pause >nul
set "AGAIN=--again"
goto ask
