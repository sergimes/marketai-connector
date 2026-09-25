# MarketAI Connector

Runs your [MarketAI](https://app.marketai.trade) bots on your own exchange accounts.

You choose a signal feed and a leverage for each bot on MarketAI's **My bots** page. The
connector receives that feed's signals and places the orders on your exchange account,
with your own API keys, on your own computer. Your keys and your money never pass
through MarketAI.

> **Trading leveraged futures can lose you money, including your whole account balance.**
> Read [DISCLAIMER.md](DISCLAIMER.md) before you start. Try it on a demo account first.
> En español: [LICENSE.es](LICENSE.es) y [DISCLAIMER.es.md](DISCLAIMER.es.md).

## What you need

- **A bot on MarketAI**, from the My bots page. Each bot has a short id (like
  `k7m3q9x2`) and a token.
- **An exchange account on Bitget or Hyperliquid for each bot**, with an API key that can
  **trade but not withdraw**.
- **A computer that stays on and awake, with Docker.** Docker Desktop on Windows or Mac,
  or Docker Engine on Linux. Both x86 and ARM work (for example a Raspberry Pi 4 or 5
  with a 64-bit system, or an Apple silicon Mac).

## Start

Get this folder, with git or as a ZIP (the green **Code** button above, then
**Download ZIP**):

```bash
git clone https://github.com/sergimes/marketai-connector.git
cd marketai-connector
```

Run the setup and choose **Add a bot**:

```bash
./setup.sh          # Linux and Mac
setup.cmd           # Windows (in PowerShell: .\setup.cmd)
```

First it asks you to accept the connector's [licence](LICENSE) and
[risk disclaimer](DISCLAIMER.md), in English or Spanish; you can read both in full right
there. Then, with a second yes, it asks you to accept the connector's characteristics:
how it works by design, listed at the end of the disclaimer. A bot does not trade until
both are accepted. When you accept, the setup saves a copy of exactly what you accepted
in this folder, as `accepted-terms-<version>-<language>-<time>.txt`. Then paste the lines My bots shows for the bot (or just
its token), then the exchange keys.
Each hidden answer shows a `*` per character. The setup checks both before saving:
MarketAI says which bot the token belongs to, and the exchange shows the account's
balance (it only reads, it never trades). Then it offers to start the bot.

Within a minute the bot's log says `Trading signal feed ...`, and My bots shows it as
**Connected**. The setup's **Show a bot's recent log** shows that line.

## The setup

Run `./setup.sh` (or `setup.cmd`) any time. It opens with each bot's state (running,
stopped, not started), then shows what it can do:

| choice | what it does |
|---|---|
| **Add a bot** | asks for the token and keys, checks them, and saves the bot |
| **Change a bot** | a new token (after making one on My bots), other exchange keys or account, the name, a leverage that overrides My bots, new entries on or off |
| **Remove a bot** | stops running it here (read the warning below first) |
| **Show my bots** | each bot's settings (tokens and keys hidden), whether it runs, and, for a running bot, what My bots says about it |
| **Start the bots** | starts every bot, and applies your changes |
| **Stop the bots** | stops every bot; open positions stay on the exchange, with their stop-loss and take-profit |
| **Show a bot's recent log** | its last 40 lines |
| **Automatic updates** | on or off |

Choose **0** to leave it, or just close its window: it then ends by itself within half a
minute, and leaves nothing running. A change is saved whole or not at all.

The same, without the setup:

```bash
docker compose up -d --remove-orphans     # start, or apply the setup's changes
docker compose logs -f                    # watch every bot (Ctrl+C stops watching)
docker compose stop                       # stop every bot
```

It refuses what would go wrong later: the same bot twice, a token that belongs to a
different bot, and two bots on one exchange account (each would trade the whole balance
as if it were its own).

## What you control on My bots

The connector follows each bot on MarketAI by itself. You never need to restart it.

| on My bots | what the connector does |
|---|---|
| **Active** | trades the signal feed |
| **Paused**, waiting for approval, not paid, or the feed is no longer offered | closes every open position, then waits |
| a state the connector does not know | the same: closes every open position, then waits |
| **Bot deleted**, or its token replaced | stops trading; open positions stay as they are, each with the stop-loss placed for it |
| **Another signal feed** | closes every open position of the old feed, then trades the new one |
| **Another leverage** | uses it for new entries; open positions keep their size |

## Updates

**The connector updates itself.** At minute 7, 22, 37 and 52 of every hour, the
`updater` checks for a new release; if there is one, it downloads it and restarts the
bots. Those minutes are the middle of each 15-minute bar, when no order is normally being
placed. Each bot's log starts with the version it runs.

**To stay on one version**, create a file named `.env` in this folder with one line, for
example `CONNECTOR_VERSION=1.0.0`, then `docker compose up -d`. Delete the file to follow
the latest release again. MarketAI can stop accepting a version that is too old; that
version's log then says so. To update by hand only, turn automatic updates off in the setup
and run `docker compose pull && docker compose up -d` when you want to.

**This folder's own files update with `git pull`** (or a fresh ZIP). Your files never
do: everything the setup writes (`bot-*.env`, `compose.override.yml`, your copy of the
accepted terms, and the short-lived `.setup-*` files) and your `.env` are ignored by
git, so a pull can never overwrite or clash with them. Do not edit
`compose.yml` or `bot-template.yml`; the setup covers everything they would need.

## Good to know

- **One exchange account per bot.** Each entry is sized from the whole account's balance,
  so two bots on one account would each trade as if they had all of it.
- **The connector places a stop-loss at the exchange for every position,** as an order
  of its own, so once placed it does not depend on the connector: it stays at the
  exchange if the connector, your computer or your internet stops. If placing it fails,
  the connector tries again every two minutes and says so in its log.
- **Keep the computer awake.** When it sleeps, the bots sleep with it: they miss every
  signal, closes included, until it wakes. Open positions keep their stop-loss and
  take-profit at the exchange. Turn sleep off in the power settings, or run the connector
  on a machine that is always on, like a small server or a Raspberry Pi.
- **Your keys stay on your computer.** The connector sends the bot token to MarketAI, and
  uses your exchange keys only with your exchange. Logs show only the first five
  characters of the token.
- **Pause before you remove or delete.** Pausing a bot on My bots closes its positions.
  Removing it here, deleting it on My bots, or replacing its token stops it but leaves
  open positions as they are, each with the stop-loss placed for it.
- **Run each bot in one place only.** If the same bot runs twice, MarketAI keeps the newer
  copy and stops the older one.
- **Try it on a demo account first:** Bitget demo API keys, and answer "yes" when the
  setup asks whether it is a demo account.

## When something is wrong

Each bot runs as `marketai-bot-<id>`. `docker compose logs -f` shows all of them; the bot's
id starts every line. The messages you are most likely to see:

| the log says | what to do |
|---|---|
| `Not starting: ...` | the rest of the line says what is missing; run the setup and **Change a bot** |
| `Opening nothing new: the connector's licence and risk disclaimer are ...` | run the setup and accept them, then **Start the bots**. Until then the bot only looks after what is already open |
| `Version ... of the licence and risk disclaimer applies from ...` | new terms are coming: run the setup and accept them before that day, then **Start the bots**. Until that day the bot trades as usual |
| `Not trading: MarketAI no longer accepts this version of the connector` | update it: turn automatic updates on in the setup, or run `docker compose pull && docker compose up -d`. If you pinned a version in `.env`, remove that line first. The bot asks again every 5 minutes |
| `Opening nothing new: HYPERLIQUID_VAULT_ADDRESS is set` | the licence does not allow trading a vault: remove that line from the bot's file, then `docker compose up -d` |
| `MarketAI refused this bot's token (401)` | make a new token on My bots, then the setup: **Change a bot**, **Its token** |
| `STOPPED: another instance of this bot connected` | the same bot runs somewhere else too; stop one, then `docker compose restart` here if this is the one you keep |
| `STOPPED: MarketAI revoked this bot's token` | the token was replaced or the bot deleted; give it the new token in the setup, then `docker compose up -d` |
| `open skipped: ... below the venue minimum` | the account is too small for the exchange's smallest order at this leverage; that leg is skipped, never rounded up |
| `open skipped: unusable equity` | the connector sees no money to trade with: fund the futures account (on Bitget, not the spot wallet) |

The full log of a bot is kept inside Docker. To copy it out:
`docker compose cp bot-k7m3q9x2:/app/logs ./logs` (with your bot's id).

## Setting it up by hand

The setup is the easy way, but it only writes two kinds of plain files. To write them
yourself, copy `bot.example.env` to `bot-<id>.env` and `compose.override.example.yml` to
`compose.override.yml`, and follow the notes inside each. Accepting the licence and
disclaimer is one of them: without `TERMS_VERSION_ACCEPTED` and
`TERMS_CHARACTERISTICS_ACCEPTED` in its file, a bot does not trade.

## What the connector sends, and to whom

- **To MarketAI:** each bot's token; the connector's version; and which version of the
  licence and disclaimer was accepted for the bot, in which language, when, and a
  fingerprint (SHA-256) of the exact text. MarketAI also sees your IP address and when
  each bot is connected. They are sent so that MarketAI can run your bots, show their
  state on My bots, and keep its own record of the acceptance.
- **To your exchange:** your orders and the reads of your account, signed with your API
  keys.
- **To GitHub:** downloading the connector, and each check for an update, go to ghcr.io,
  which sees your IP address. GitHub's privacy statement applies.
- **To Docker Hub:** downloading the updater (watchtower), which sees your IP address.

Nothing else leaves your computer. Your bots' logs stay on it, unless you send them to us.

## Licence, risk and security

The connector is free to run with your own MarketAI bots; see [LICENSE](LICENSE)
(en español, [LICENSE.es](LICENSE.es)). It comes as it is, and every order it places is
yours: sections 8 to 10 say what that means, and which rights you keep as a consumer. Read [DISCLAIMER.md](DISCLAIMER.md)
(en español, [DISCLAIMER.es.md](DISCLAIMER.es.md)).

What each release changes is in the
[release notes](https://github.com/sergimes/marketai-connector/releases). To report a
security problem, see [SECURITY.md](SECURITY.md).
