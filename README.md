# MarketAI Connector

Runs your [MarketAI](https://app.marketai.trade) bot on your own exchange account.

You choose a signal feed and a leverage on MarketAI's **My bots** page. The connector
receives that feed's signals and places the orders on your exchange account, with your
own API keys, on your own computer. Your keys and your money never pass through MarketAI.

> **Trading leveraged futures can lose you money, including your whole account balance.**
> Read [DISCLAIMER.md](DISCLAIMER.md) before you start. Try it on a demo account first.

## What you need

- **A bot on MarketAI.** Create it on the My bots page. It shows two lines to copy:
  `MARKETAI_HOST` and `MARKETAI_BOT_TOKEN`.
- **An exchange account on Bitget or Hyperliquid**, with an API key that can **trade but
  not withdraw**. Use one account (or sub-account) per bot.
- **A computer that stays on, with Docker.** Docker Desktop on Windows or Mac, or Docker
  Engine on Linux. Both x86 and ARM work (for example a Raspberry Pi 4 or 5 with a 64-bit
  system, or an Apple silicon Mac).

## Start

```bash
git clone https://github.com/sergimes/marketai-connector.git
cd marketai-connector
cp bot.example.env bot.env        # on Windows: copy bot.example.env bot.env
```

Open `bot.env` in a text editor. Paste your two lines from My bots, and fill in your
exchange keys. Then:

```bash
docker compose up -d
docker compose logs -f connector
```

Within a minute the log says `Trading signal feed ...`, and My bots shows your bot as
**Connected**. Press Ctrl+C to stop watching the log; the connector keeps running.

To stop it: `docker compose down`. To start it again: `docker compose up -d`.

## What you control on My bots

The connector follows your bot on MarketAI by itself. You never need to restart it.

| on My bots | what the connector does |
|---|---|
| **Active** | trades the signal feed |
| **Paused**, waiting for approval, or the feed is no longer offered | closes every open position, then waits |
| **Another signal feed** | closes every open position of the old feed, then trades the new one |
| **Another leverage** | uses it for new entries; open positions keep their size |

`OPEN_LEVERAGE` in `bot.env` overrides the leverage on My bots. Leave it out unless you
mean that.

## Updates

The `updater` service checks for a new release at minute 7, 22, 37 and 52 of every hour.
When there is one, it downloads it and restarts the connector. Those minutes are the
middle of each 15-minute bar, so an update never cuts an order short. It touches only the
connector, nothing else on your computer.

- **To stay on one version:** in `compose.yml`, replace `:latest` with a version, for
  example `ghcr.io/sergimes/marketai-connector:1.0.0`, then `docker compose up -d`.
- **To update by hand instead:** delete the `updater` service from `compose.yml`, and run
  `docker compose pull && docker compose up -d` when you want to update.

The log's first line says which version is running.

## Good to know

- **One bot per exchange account.** Each entry is sized from the whole account's balance,
  so two bots on one account would each trade as if they had all of it.
- **Every position has its stop-loss at the exchange.** If the connector, your computer or
  your internet stops, the stop-loss still works.
- **Your keys stay on your computer.** The connector sends the bot token to MarketAI, and
  your exchange keys only to your exchange. Logs show only the first five characters of
  the token.
- **Pause before you delete.** Pausing a bot closes its positions. Deleting a bot, or
  replacing its token, stops the connector but leaves open positions as they are.
- **Run one copy per bot.** If you start the same bot twice, MarketAI keeps the newer copy
  and stops the older one (see below).
- **Try it on a demo account first:** use Bitget demo API keys and set `BITGET_DEMO=true`
  in `bot.env`.

## More than one bot

Each bot needs its own exchange account (or sub-account), its own settings file and its
own name. Copy the `connector` service in `compose.yml`, give the copy another service
name, `container_name` and `env_file` (for example `bot2.env`), and set a different
`NAME=` in that file. The one `updater` service keeps both up to date.

## When something is wrong

The connector says what is wrong in plain words. The messages you are most likely to see:

| the log says | what to do |
|---|---|
| `Not starting: ...` | the rest of the line says what to fix in `bot.env` |
| `MarketAI refused this bot's token (401)` | copy the token again from My bots, or create a new one, put it in `bot.env`, then `docker compose up -d` |
| `STOPPED: another instance of this bot connected` | the same bot runs somewhere else too; stop one of them, then `docker compose restart connector` on the one you keep |
| `STOPPED: MarketAI revoked this bot's token` | the token was replaced or the bot deleted; put the new token in `bot.env`, then `docker compose up -d` |
| `open skipped: ... below the venue minimum` | the account is too small for the exchange's smallest order at this leverage; that leg is skipped, never rounded up |
| `open skipped: unusable equity` | the connector sees no money to trade with: fund the futures account (on Bitget, not the spot wallet) |

The full log is kept inside Docker. To copy it out:
`docker compose cp connector:/app/logs ./logs`.

## Licence and risk

The connector is free to run with your own MarketAI bot; see [LICENSE](LICENSE). It comes
with no warranty. Read [DISCLAIMER.md](DISCLAIMER.md).
