# MarketAI Connector

Runs your [MarketAI](https://app.marketai.trade) bots on your own exchange accounts.

You choose a signal feed and a leverage for each bot on MarketAI's **My bots** page. The
connector receives that feed's signals and places the orders on your exchange account,
with your own API keys, on your own computer. Your keys and your money never pass
through MarketAI.

> **Trading leveraged futures can lose you money, including your whole account balance.**
> Read [DISCLAIMER.md](DISCLAIMER.md) before you start. Try it on a demo account first.

## What you need

- **A bot on MarketAI**, from the My bots page. Each bot has a short id (like
  `k7m3q9x2`) and a token.
- **An exchange account on Bitget or Hyperliquid for each bot**, with an API key that can
  **trade but not withdraw**.
- **A computer that stays on, with Docker.** Docker Desktop on Windows or Mac, or Docker
  Engine on Linux. Both x86 and ARM work (for example a Raspberry Pi 4 or 5 with a 64-bit
  system, or an Apple silicon Mac).

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

It asks for the bot's token and the exchange keys, and checks both before saving:
MarketAI says which bot the token belongs to, and the exchange shows the account's
balance (it only reads, it never trades). Then start it:

```bash
docker compose up -d --remove-orphans
docker compose logs -f
```

Within a minute the log says `Trading signal feed ...`, and My bots shows the bot as
**Connected**. Press Ctrl+C to stop watching the log; the bots keep running.

To stop them: `docker compose down`. To start them again: `docker compose up -d`.

## The setup

Run `./setup.sh` (or `setup.cmd`) any time. It shows what it can do:

| choice | what it does |
|---|---|
| **Add a bot** | asks for the token and keys, checks them, and saves the bot |
| **Change a bot** | a new token (after making one on My bots), other exchange keys or account, the name, a leverage that overrides My bots, new entries on or off |
| **Remove a bot** | stops running it here (read the warning below first) |
| **Show my bots** | lists them, with tokens and keys hidden |
| **Automatic updates** | on or off |

After a change, apply it with `docker compose up -d --remove-orphans`.

It refuses what would go wrong later: the same bot twice, a token that belongs to a
different bot, and two bots on one exchange account (each would trade the whole balance
as if it were its own).

## What you control on My bots

The connector follows each bot on MarketAI by itself. You never need to restart it.

| on My bots | what the connector does |
|---|---|
| **Active** | trades the signal feed |
| **Paused**, waiting for approval, or the feed is no longer offered | closes every open position, then waits |
| **Another signal feed** | closes every open position of the old feed, then trades the new one |
| **Another leverage** | uses it for new entries; open positions keep their size |

## Updates

**The connector updates itself.** At minute 7, 22, 37 and 52 of every hour, the
`updater` checks for a new release; if there is one, it downloads it and restarts the
bots. Those minutes are the middle of each 15-minute bar, so an update never cuts an
order short. Each bot's log starts with the version it runs.

**To stay on one version**, create a file named `.env` in this folder with one line, for
example `CONNECTOR_VERSION=0.3.0`, then `docker compose up -d`. Delete the file to follow
the latest release again. To update by hand only, turn automatic updates off in the setup
and run `docker compose pull && docker compose up -d` when you want to.

**This folder's own files update with `git pull`** (or a fresh ZIP). Your files never
do: everything the setup writes (`bot-*.env`, `compose.override.yml`) and your `.env` are
ignored by git, so a pull can never overwrite or clash with them. Do not edit
`compose.yml` or `bot-template.yml`; the setup covers everything they would need.

## Good to know

- **One exchange account per bot.** Each entry is sized from the whole account's balance,
  so two bots on one account would each trade as if they had all of it.
- **Every position has its stop-loss at the exchange.** If the connector, your computer or
  your internet stops, the stop-loss still works.
- **Your keys stay on your computer.** The connector sends the bot token to MarketAI, and
  your exchange keys only to your exchange. Logs show only the first five characters of
  the token.
- **Pause before you remove or delete.** Pausing a bot on My bots closes its positions.
  Removing it here, deleting it on My bots, or replacing its token stops it but leaves
  open positions as they are, each with its stop-loss.
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
`compose.override.yml`, and follow the notes inside each.

## Licence and risk

The connector is free to run with your own MarketAI bots; see [LICENSE](LICENSE). It
comes with no warranty. Read [DISCLAIMER.md](DISCLAIMER.md).
