#!/bin/sh
# MarketAI Connector setup: add, change or remove the bots in this folder, start or
# stop them, and see how they are doing.
#
#   ./setup.sh
#
# The questions run inside the connector image, as you, on this folder, so they need
# nothing but Docker. They write only your own files (bot-*.env, compose.override.yml).
# Starting and stopping the bots runs here, with docker compose: a container cannot
# start or stop other containers unless it is given control of Docker, and the setup
# is not.
set -e
cd "$(dirname "$0")"
# Git Bash on Windows: keep /work as it is, and give Docker this folder's Windows path.
export MSYS_NO_PATHCONV=1
here=$(pwd -W 2> /dev/null || pwd)

version=$(sed -n 's/^CONNECTOR_VERSION=//p' .env 2>/dev/null | tr -d '\r' | tail -n 1)
image="ghcr.io/sergimes/marketai-connector:${version:-latest}"

docker pull -q "$image" > /dev/null

again=""
while :; do
    # What Docker says about the bots, for the setup to show. Nothing else is shared.
    docker compose ps -a --format json > .setup-status.json 2> /dev/null \
        || rm -f .setup-status.json
    rm -f .setup-action
    # While the setup runs, keep a heartbeat file fresh from this window, one per run.
    # Closing the window stops this too, and the setup then ends itself within half a
    # minute: Docker would otherwise keep it running, waiting for an answer that never
    # comes. (In a folder it cannot write, the setup says so itself.)
    alive=".setup-alive-$$"
    touch "$alive" 2> /dev/null || true
    ( while touch "$alive" 2> /dev/null; do sleep 5; done ) &
    beat=$!
    status=0
    docker run --rm -it --user "$(id -u):$(id -g)" -v "$here:/work" \
        -e SETUP_ACTIONS=1 -e SETUP_HEARTBEAT="$alive" "$image" setup $again "$@" \
        || status=$?
    kill "$beat" 2> /dev/null || true
    action=$(cat .setup-action 2> /dev/null || true)
    rm -f .setup-status.json .setup-action "$alive"
    [ "$status" -eq 0 ] || exit "$status"

    # The setup asked for one of these, and nothing else is run. .setup-pending (changes
    # saved, not applied yet) goes only once Docker has applied them.
    case "$action" in
        start|start-exit)
            if docker compose up -d --remove-orphans; then
                rm -f .setup-pending
            else
                echo "Docker could not start the bots. See the messages above."
            fi
            [ "$action" = start ] || exit 0 ;;
        stop)
            # Apply the changes first: a bot removed here is no longer in the files, and
            # `docker compose stop` alone would leave it running.
            if docker compose up --no-start --remove-orphans && docker compose stop; then
                rm -f .setup-pending
            else
                echo "Docker could not stop the bots. See the messages above."
            fi ;;
        "logs bot-"*)
            service=${action#logs }
            case "$service" in *[!a-z0-9-]*) exit 1 ;; esac
            docker compose logs --tail 40 --no-log-prefix "$service" || true ;;
        *)
            exit 0 ;;
    esac
    printf '\nPress Enter to go back to the setup. '
    read -r _ || exit 0
    again="--again"
done
