# MarketAI Connector

The MarketAI Connector runs your [MarketAI](https://app.marketai.trade) bots on your own
exchange accounts.

You choose a signal feed and a leverage for each bot on MarketAI's **My bots** page. The
connector receives that feed's signals and places the orders on your exchange account,
with your own API keys, on your own computer. Your API keys and your funds never pass
through MarketAI.

A bot runs on one of two kinds of account:

- **crypto futures on Bitget or Hyperliquid**, following a signal feed's signals;
- **US stocks on Alpaca**, for a bot on one of your own rule feeds: the connector keeps
  the account in line with the bot's target portfolio (see
  [Investing in US stocks with Alpaca](#investing-in-us-stocks-with-alpaca)).

> **Trading leveraged futures, or investing with borrowed money, can lose you money,
> including your entire account balance.** Please read the
> [risk disclaimer](DISCLAIMER.md) before you start, and try the connector on a demo or
> paper account first.
> En español: [LICENSE.es](LICENSE.es) y [DISCLAIMER.es.md](DISCLAIMER.es.md).

## Requirements

- **A bot on MarketAI**, created on the My bots page. Each bot has a short id (such as
  `k7m3q9x2`) and a token.
- **One exchange account for each bot**: on Bitget or Hyperliquid, with an API key that
  can **trade but not withdraw**; or on Alpaca, with the account's API keys (a paper
  account and a live account each have their own).
- **A computer that stays on and awake, with Docker**: Docker Desktop on Windows or Mac,
  or Docker Engine on Linux. Both x86 and ARM are supported, for example a Raspberry Pi 4
  or 5 with a 64-bit system, or an Apple silicon Mac.

## Getting started

Download this repository with git, or as a ZIP file (the green **Code** button above,
then **Download ZIP**):

```bash
git clone https://github.com/sergimes/marketai-connector.git
cd marketai-connector
```

Run the setup and choose **Add a bot**:

```bash
./setup.sh          # Linux and Mac
setup.cmd           # Windows (in PowerShell: .\setup.cmd)
```

The setup first asks you to accept the connector's [licence](LICENSE) and
[risk disclaimer](DISCLAIMER.md), in English or Spanish; both can be read in full from the
setup. It then asks you to accept, separately, the connector's characteristics: how it
works by design, as listed at the end of the disclaimer. A bot does not trade until both
are accepted. The setup saves a copy of exactly what you accepted in this folder, as
`accepted-terms-<version>-<language>-<time>.txt`.

Next, paste the lines shown for the bot on the My bots page (or only its token), followed
by the exchange's API keys. Hidden input shows an asterisk for each character. The setup
verifies both before saving: MarketAI confirms which bot the token belongs to, and the
exchange reports the account's balance (this check only reads; it never trades). The
setup then offers to start the bot.

Within a minute, the bot's log reports `Trading signal feed ...` (on Alpaca:
`The bot is active: it follows its target portfolio ...`), and the My bots page shows the
bot as **Connected**. You can see that line with **Show a bot's recent log** in the
setup.

## The setup

You can run `./setup.sh` (or `setup.cmd`) at any time. It shows the state of each bot
(running, stopped or not started), followed by these options:

| option | what it does |
|---|---|
| **Add a bot** | asks for the token and API keys, verifies them, and saves the bot |
| **Change a bot** | changes its token (after you create a new one on My bots), its exchange keys or account, its name, a leverage that overrides My bots, or turns new entries on or off |
| **Remove a bot** | stops running the bot on this computer (please read the note on removing below first) |
| **Show my bots** | shows each bot's settings (tokens and keys hidden), whether it is running, and, for a running bot, what My bots reports about it |
| **Start the bots** | starts every bot and applies your changes |
| **Stop the bots** | stops every bot; open positions remain on the exchange, with their stop-loss and take-profit |
| **Show a bot's recent log** | shows the last 40 lines of its log |
| **Automatic updates** | turns automatic updates on or off |

Choose **0** to leave the setup, or simply close its window: the setup then ends within
half a minute and leaves nothing running. Every change is saved completely or not at all.

The same actions are available without the setup:

```bash
docker compose up -d --remove-orphans     # start, or apply the setup's changes
docker compose logs -f                    # follow every bot's log (Ctrl+C to stop)
docker compose stop                       # stop every bot
```

The setup prevents configurations that would cause problems later: the same bot set up
twice, a token that belongs to a different bot, and two bots on one exchange account
(each would trade the whole balance as if it were its own).

## What you control on My bots

The connector follows each bot's settings on MarketAI automatically. You never need to
restart it.

| on My bots | what the connector does |
|---|---|
| **Active** | trades the signal feed |
| **Paused**, waiting for approval, not paid, or the feed is no longer offered | closes every open position, then waits |
| a state the connector does not recognise | closes every open position, then waits |
| **Bot deleted**, or its token replaced | stops trading; open positions remain as they are, each with the stop-loss placed for it |
| **Another signal feed** | closes every open position of the previous feed, then trades the new one |
| **Another leverage** | uses it for new entries; open positions keep their size |

A bot on Alpaca follows the same settings in its own way: see the next section.

## Investing in US stocks with Alpaca

A bot on one of your own **rule feeds** can invest in US stocks on an
[Alpaca](https://alpaca.markets) account. In the setup, choose **Add a bot**, then
**Alpaca (US stocks, for a bot on a rule feed)**, and paste the account's API key ID and
secret key from Alpaca's dashboard. The setup checks them with one read of the account,
and tells you its value and whether it can borrow.

After each bar, MarketAI sends the bot's **target portfolio**: the share of the account's
value to hold in each stock of the feed. The connector brings the account to it:

- **When the market is open.** A target that arrives after the close is applied at the
  next open. Orders fill only during regular US market hours.
- **Sales first, then purchases.** What the feed buys at the open is bought at the open,
  at any price. Anything else the account is short of (a bar the connector missed, an
  order Alpaca refused, a deposit) is bought only at or below the price limit MarketAI
  sends, so the account can hold less than its target. The log names each purchase
  skipped and why.
- **Leverage.** At 1x the bot buys only with the account's cash. Above 1x it borrows from
  Alpaca up to the bot's leverage, and never beyond what Alpaca lends overnight. An
  account that cannot borrow invests at 1x.
- **Stop-loss and take-profit.** They are the bot's own settings on My bots, placed at
  Alpaca as soon as each purchase fills. A bot with no stop-loss setting has none. Whole
  shares carry their stop-loss until it is cancelled; a fraction of a share carries one
  for the current trading day only, placed again each day while the connector runs.
- **Only its own markets and orders.** The connector trades only the stocks the target
  lists, and cancels only the orders it placed. Shares you hold in other stocks are left
  alone; shares of the feed's stocks are part of what it brings to the target.
- **Paused, or any state other than active.** The connector sells, at market and while
  the market is open, the shares it holds in the feed's stocks, and buys nothing. The same
  happens if the bot is moved to one of MarketAI's own signal feeds, which send no target
  portfolio.

**Start with an Alpaca paper account.** Its API keys start with PK, and the setup then
suggests "yes" when it asks whether it is a paper account. Alpaca's own rules, such as
those on day trading and on margin, still apply to the account, and can refuse an order
or restrict the account.

## Updates

**The connector updates itself.** At minute 7, 22, 37 and 52 of every hour, the
`updater` checks for a new release; when there is one, it downloads it and restarts the
bots. These minutes fall in the middle of each 15-minute bar, when no order is normally
being placed. Each bot's log starts with the version it runs.

**To stay on a specific version**, create a file named `.env` in this folder containing
one line, for example `CONNECTOR_VERSION=1.0.0`, then run `docker compose up -d`. Delete
the file to follow the latest release again. MarketAI may stop accepting a version that
is too old, in which case that version's log says so. To update only manually, turn
automatic updates off in the setup and run `docker compose pull && docker compose up -d`
whenever you choose.

**This folder's own files are updated with `git pull`** (or a new ZIP). Your own files are
never affected: everything the setup writes (`bot-*.env`, `compose.override.yml`, your
copies of the accepted terms, and the temporary `.setup-*` files) and your `.env` are
ignored by git, so an update never overwrites or conflicts with them. Please do not edit
`compose.yml` or `bot-template.yml`; the setup covers everything they would need.

## Good to know

- **One exchange account per bot.** Each entry is sized from the whole account's balance,
  so two bots on one account would each trade as if they had all of it.
- **The connector places a stop-loss at the exchange for every position,** as an order of
  its own (on Alpaca, when the bot has a stop-loss setting). Once placed, it does not
  depend on the connector: it stays at the exchange if the connector, your computer or
  your internet connection stops. If placing it fails, the connector retries and reports
  it in its log.
- **Keep the computer awake.** While the computer sleeps, the bots cannot act: they miss
  every signal, including closes, until it wakes. Open positions keep their stop-loss and
  take-profit at the exchange. Turn sleep off in the power settings, or run the connector
  on a machine that is always on, such as a small server or a Raspberry Pi.
- **Your keys stay on your computer.** The connector sends the bot token only to MarketAI,
  and uses your exchange keys only with your exchange. Logs show only the first five
  characters of the token.
- **Pause a bot before you remove or delete it.** Pausing a bot on My bots closes its
  positions. Removing it here, deleting it on My bots, or replacing its token stops it but
  leaves open positions as they are, each with the stop-loss placed for it.
- **Run each bot in one place only.** If the same bot runs twice, MarketAI keeps the newer
  instance and stops the older one.
- **Start with a demo account.** Use Bitget demo API keys, and answer "yes" when the setup
  asks whether it is a demo account; on Alpaca, use a paper account.

## Troubleshooting

Each bot runs as `marketai-bot-<id>`. `docker compose logs -f` shows the logs of all bots,
and each line starts with the bot's id. These are the messages you are most likely to
see:

| the log says | what to do |
|---|---|
| `Not starting: ...` | The rest of the line says what is missing. Run the setup and choose **Change a bot**. |
| `No new positions will be opened: the connector's licence and risk disclaimer are ...` | Run the setup, accept the terms, then choose **Start the bots**. Until then, the bot continues to manage its open positions. |
| `Version ... of the licence and risk disclaimer takes effect on ...` | New terms are coming. Run the setup and accept them before that date, then choose **Start the bots**. Until then, the bot trades as usual. |
| `Not trading: MarketAI no longer accepts this version of the connector` | Update the connector: turn automatic updates on in the setup, or run `docker compose pull && docker compose up -d`. If you pinned a version in `.env`, remove that line first. The bot checks again every 5 minutes. |
| `No new positions will be opened: HYPERLIQUID_VAULT_ADDRESS is set` | The licence does not permit trading a vault. Remove that line from the bot's settings file, then run `docker compose up -d`. |
| `MarketAI refused this bot's token (401)` | Create a new token on the My bots page, then run the setup and choose **Change a bot**, then **Its token**. |
| `STOPPED: another instance of this bot connected` | The same bot is running somewhere else. Stop one of them; if this is the one to keep, run `docker compose restart` here. |
| `STOPPED: MarketAI revoked this bot's token` | The token was replaced or the bot was deleted. Give the bot its new token in the setup, then run `docker compose up -d`. |
| `open skipped: ... below the venue minimum` | The account is too small for the exchange's smallest order at this leverage. That market is skipped; an order is never rounded up to the minimum. |
| `open skipped: unusable equity` | The connector finds no funds to trade with. Fund the futures account (on Bitget, not the spot wallet). |
| `... one of MarketAI's own signal feeds ... an Alpaca account cannot follow them` | An Alpaca bot needs a rule feed. Choose one of your rule feeds for the bot on the My bots page. |
| `The market is closed. The target portfolio is applied when it opens, at ...` | Nothing to do: the bot waits for the US market to open. |
| `... a catch-up purchase of ... was not placed, because the market is above its price limit` | Nothing to do: the stock is above the price MarketAI allows for a late purchase. The bot tries again with the next target. |
| `The bot's leverage is ...x, but this Alpaca account cannot borrow` | The account is a cash account, so the bot invests at 1x. Enable margin at Alpaca, or set the bot's leverage to 1 on My bots. |
| `The Alpaca paper account could not be read` (or live account) | Alpaca did not accept the keys, or did not answer. Check the keys in the setup with **Change a bot**; a paper account's keys work only for paper trading. |

The complete log of each bot is kept inside Docker. To copy it out, run
`docker compose cp bot-k7m3q9x2:/app/logs ./logs` (with your bot's id).

## Manual configuration

The setup is the simplest way, but it only writes two kinds of plain files. To write them
yourself, copy `bot.example.env` to `bot-<id>.env` and `compose.override.example.yml` to
`compose.override.yml`, and follow the notes in each. Accepting the licence and
disclaimer is part of this: without `TERMS_VERSION_ACCEPTED` and
`TERMS_CHARACTERISTICS_ACCEPTED` in its file, a bot does not trade.

## What the connector sends, and to whom

- **To MarketAI:** each bot's token; the connector's version; and which version of the
  licence and disclaimer was accepted for the bot, in which language, when, and a
  fingerprint (SHA-256) of the exact text. MarketAI also sees your IP address and when
  each bot is connected. This information is sent so that MarketAI can run your bots,
  show their state on My bots, and keep its own record of the acceptance.
- **To your exchange:** your orders and the reads of your account, signed with your API
  keys.
- **To GitHub:** downloading the connector, and each check for an update, goes to ghcr.io,
  which sees your IP address. GitHub's privacy statement applies.
- **To Docker Hub:** downloading the updater (watchtower), which sees your IP address.

Nothing else leaves your computer. Your bots' logs stay on it unless you choose to send
them to us.

## Licence, risk and security

The connector is free to use with your own MarketAI bots under its [licence](LICENSE)
(en español, [LICENSE.es](LICENSE.es)). It is provided as it is, and every order it places
is yours: sections 8 to 10 of the licence explain what this means and which rights you
keep as a consumer. Please read the [risk disclaimer](DISCLAIMER.md) as well (en español,
[DISCLAIMER.es.md](DISCLAIMER.es.md)).

The [release notes](https://github.com/sergimes/marketai-connector/releases) describe what
each release changes. To report a security problem, please follow
[SECURITY.md](SECURITY.md).
