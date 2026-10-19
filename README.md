# MarketAI Connector

The MarketAI Connector runs your [MarketAI](https://app.marketai.trade) bots on your own
exchange accounts.

You choose a feed and a leverage for each bot on MarketAI's **My bots** page. The
connector receives what that feed sends and places the orders on your exchange account,
with your own API keys, on your own computer. Your API keys and your funds never pass
through MarketAI.

A bot runs on one of two kinds of account:

- **crypto futures on Bitget or Hyperliquid**, following a feed's signals;
- **US stocks on Alpaca**, for a bot on a feed built on your own rules: the connector keeps
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
- **For a bot on Alpaca**: the bot must be on a locked feed built on your own rules, and
  the Alpaca account must be in US dollars. To use a leverage above 1x, it must be a
  margin account. See [Investing in US stocks with
  Alpaca](#investing-in-us-stocks-with-alpaca).
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

Next, paste the bot's token, followed by the exchange's API keys. The token starts with
`bot_`; pasting the whole block of lines My bots shows for the bot works too. My bots
shows a token only once, when the bot is created: if you did not copy it, choose
**Regenerate token** there, and the old one stops working. Hidden input shows an
asterisk for each character. The setup verifies the token and the keys before saving:
MarketAI confirms which bot the token belongs to, and the exchange reports the account's
balance (this check only reads; it never trades). The setup then offers to start the
bot.

Within a minute, the bot's log reports `Trading feed ...` (on Alpaca:
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
| **Active** | follows its feed: trades its signals or, on Alpaca, its target portfolio |
| **Paused**, waiting for MarketAI's approval, or the feed is no longer available | closes every open position, then waits |
| a state the connector does not recognise | closes every open position, then waits |
| **Bot deleted**, or its token replaced | stops trading; open positions remain as they are, each with the stop-loss placed for it |
| **Another leverage** | uses it for new entries; open positions keep their size |

**A bot follows one feed for its whole life.** To follow another feed, pause the bot on My
bots and wait until the connector has closed its positions (on Alpaca, it sells them only
while the market is open). Then delete the bot on My bots and create a new bot on the
other feed. In the setup, choose **Remove a bot** for the old bot, then **Add a bot** with
the new token and the same exchange keys. Deleting a bot that is still active leaves its
positions open on the exchange: the connector just stops.

A bot on Alpaca follows the same settings in its own way: see the next section.

## Investing in US stocks with Alpaca

A bot on a feed built on your own rules can invest in US stocks on an
[Alpaca](https://alpaca.markets) account.

**Before you start:**

1. **A locked feed.** Bots follow locked feeds only: a draft is a sandbox. On MarketAI,
   either open your ruleset on the **Rulesets** page, choose **Lock the rules**, and
   **Build a feed** on it (for example on the S&P 500); or, on **Templates**, choose **Use
   this template** and choose **Locked copy**. Your feeds are listed on **Feeds**.
2. **A bot on that feed.** On **My bots**, choose **New bot** (or **Use for a bot** on the
   feed's page), choose the feed, a
   leverage and the limits ("Most in one market", and "Most to pay above the paper
   portfolio's price", 2% by default; see below), and copy the token shown. The bot is
   active from the start, and receives its target once MarketAI has approved your
   account. It takes its ruleset's stop-loss and take-profit; its card shows them under
   Settings.
3. **An Alpaca account in US dollars.** In Alpaca's dashboard, create the account's API
   keys (a paper account and a live account each have their own). A cash account invests
   at 1x; a leverage above 1x needs a margin account.
4. **The setup.** Choose **Add a bot**, paste the bot's token, choose **Alpaca (US
   stocks, for a bot on one of your own feeds)**, paste the API key ID and secret key,
   say whether it is a paper account, and give the bot a name. The setup checks the keys
   with one read of the account, and tells you its value and whether it can borrow.

After each bar, MarketAI sends the bot's **target portfolio**: the percentage of the
account's value to hold in each stock of the feed. The connector brings the account to it:

- **When it trades.** On a daily feed, the target arrives in the evening, after the US
  market closes, and the connector trades at the next open, 9:30 New York time. Orders
  fill only during regular US market hours. Keep the connector running at the open. If it
  applies the target more than 15 minutes after the open, that day's purchases at the
  open become catch-ups, and a stock the feed buys for the first time that day is not
  bought until a later target gives it a price limit.
- **A new bot's first days.** A new bot starts from what its feed's history holds:
  within a minute of its creation if the feed has already evaluated a bar, otherwise at
  the feed's first evaluation (on a daily feed, the evening after the feed is locked).
  It holds nothing until then. Every one of those positions is a catch-up, so at the
  first open the connector buys each one only at or below its price limit. A stock
  already above it is not bought then; the log says so, and the bot tries again with
  each new target.
- **Sales first, then purchases.** Sales are at market. What the feed buys at the open is
  bought with a market order in the first minutes after the open, at any price. Anything
  else the account is short of (a bar the connector missed, an order Alpaca refused, a
  deposit) is a **catch-up**: it is bought only at or below the price limit MarketAI sends
  (the price the paper portfolio paid, plus the bot's "most to pay above" setting), so the
  account can hold less than its target. The log names each purchase skipped and why.
- **Leverage.** Every target is multiplied by the bot's leverage. At 1x the bot buys only
  with the account's cash. Above 1x it borrows from Alpaca up to the bot's leverage,
  within what Alpaca lends overnight at the time of each purchase. An account that cannot
  borrow invests at 1x. A change of leverage on My bots resizes every position at the
  next target. Alpaca charges interest on the money borrowed.
- **Stop-loss and take-profit.** They are the bot's own settings on My bots, placed at
  Alpaca as soon as each purchase fills. A bot with no stop-loss setting has none. Whole
  shares carry both until they are cancelled; a fraction of a share carries only its
  stop-loss, for the current trading day, placed again each day while the connector runs.
  If the price is already past a level when its order is placed, the position is sold at
  market.
- **Only its own markets and orders.** The connector trades only the stocks the target
  lists, and cancels only the orders it placed. Shares you hold in other stocks are left
  alone; every share of the feed's stocks counts as the bot's, whoever bought it, so use
  an Alpaca account for this bot alone.
- **Paused, or any state other than active.** The connector sells at market, at once or
  at the next open, every share the account holds in the feed's stocks, and buys nothing.

**Start with an Alpaca paper account.** Its API keys start with PK, and the setup then
suggests "yes" when it asks whether it is a paper account. Alpaca's own rules, such as
those on day trading and on margin, still apply to the account, and can refuse an order
or restrict the account; a smaller margin account can be restricted by the day-trading
rules when a stop-loss sells a stock bought the same day.

## Updates

**The connector updates itself.** At minute 7, 22, 37 and 52 of every hour, the
`updater` checks for a new release; when there is one, it downloads it and restarts the
bots. These minutes fall in the middle of each 15-minute bar, when no order is normally
being placed. On Alpaca, minute 37 falls in the first minutes after the open, when
purchases may still be filling; after such a restart the connector applies the target
again from a fresh reading of the account. Each bot's log starts with the version it
runs.

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
  your internet connection stops (on Alpaca, a fraction of a share's stop-loss lasts only
  to the end of that trading day). If placing it fails, the connector retries and reports
  it in its log.
- **Keep the computer awake.** While the computer sleeps, the bots cannot act: they miss
  every signal, including closes, until it wakes. Open positions keep their stop-loss and
  take-profit at the exchange (on Alpaca, a fraction of a share's stop-loss only to the end
  of that trading day). Turn sleep off in the power settings, or run the connector
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
| `... one of MarketAI's own feeds ... an Alpaca account cannot follow them` | An Alpaca bot needs a feed built on your own rules, and a bot's feed cannot be changed. Pause this bot, create a new bot on one of your locked feeds, then in the setup remove this bot and add the new one. |
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
