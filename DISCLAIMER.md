# Risk disclaimer

Read this before you run the MarketAI Connector with real money. En español:
[DISCLAIMER.es.md](DISCLAIMER.es.md).

**You can lose money, including more than you expect.** On a crypto exchange, the
connector trades perpetual futures with leverage. When the price moves against a
leveraged position, you lose a multiple of that move: at 3x leverage, a 10% move against
you loses you about 30% of the money in that position. With cross margin, a large enough
loss can take your whole account balance. On Alpaca, the connector buys US shares, with
money borrowed from Alpaca when the bot's leverage is above 1x. A loss on borrowed money
is yours too: at 2x, a 10% fall in your shares loses you about 20% of your account's
value, and Alpaca can ask you for more funds (a margin call) or sell your shares itself.
Alpaca charges interest on the money you borrow, and in a sharp fall the loss can exceed
your account's value.

**Signals are not personal advice.** MarketAI's own signal feeds come from statistical
models, and everyone who follows one gets the same signals, whatever their situation. A
rule feed follows rules that you set yourself; on Alpaca, the target portfolio is your
bot's own simulated portfolio, worked out from those rules and your bot's settings. We do
not check whether this trading suits you, your money or your experience. Backtests and
past live results do not predict future results. A feed can lose money for long periods.

**Every order is yours.** The signals come from MarketAI; the choice to follow them
automatically is yours. Once you start the connector, it places, changes and cancels
orders on your account by itself, without asking you first. By running it, you authorise
those orders, and they and their results are yours, whatever caused them. If a failure of
the connector or of MarketAI's service causes you a loss, LICENSE section 10 says whether
we must compensate you: if you use the connector for a business, we do not, except for
wilful misconduct or gross negligence; if you are a consumer, we do so as the law
provides, and no further. Check your exchange account regularly, and stop the connector
at once if you see an order you did not expect. To stop it trading, pause your bots on My
bots, which closes their positions (on Alpaca, sells them while the market is open), or
stop the connector, which leaves them open with their stop-loss and take-profit (on
Alpaca, the stop-loss of a fraction of a share lapses at the end of that trading day).

**Orders do not always fill as planned.** A stop-loss fires as a market order and can fill
worse than its trigger price in a fast market. A take-profit rests on the order book as a
limit order and can be missed when the price only touches it. Exchanges, networks,
MarketAI and your own computer can fail or be slow. On a crypto exchange, a signal sent
while the connector is offline is not sent again; on Alpaca, the connector applies the
latest target portfolio when it reconnects, within the limits described below. On
Alpaca, orders fill only while the US market is open. A stop-loss fires only then, so a
share whose price opens below its stop-loss is sold at about the opening price, below the
stop-loss's price.

**An investing bot on Alpaca follows a target portfolio.** After each bar (each day, on
a daily feed), MarketAI sends the percentage of the account's value to hold in each
market of the bot's feed, and the connector buys and sells to match it (LICENSE section
8.5). Every sale it makes to follow the target is at market. What the feed buys at the
open, the connector buys with a market order in the first minutes after the open, at any
price, which can differ from the opening price the feed uses. Anything else the account
is short of (a bar the connector missed, an order Alpaca refused, a deposit) it buys
only at or below the price limit MarketAI sends, and not at all when MarketAI sends
none; such a purchase that does not fill within minutes is cancelled until the next
target. The account can therefore hold less than the target, and its results can differ
from the bot's simulated portfolio. The stop-loss and take-profit are the bot's own
settings on My bots: a bot with no stop-loss has none. The stop-loss of a position
bought at the open is first measured from the first trades after the open, and moved to
the official opening price once Alpaca publishes it, about a quarter of an hour later.
Whole shares carry their stop-loss and take-profit until they are cancelled: by the
connector while it buys more of that stock, when Alpaca's rules require it, or by Alpaca
under its own rules; while the connector runs, it places them again. A fraction of a
share carries only its stop-loss (its take-profit if it has no stop-loss), for the
current trading day, placed again each day while the connector runs. If the price is
already past a level when its order is placed, the connector sells at market. Alpaca's
own rules, such as those on day trading and on margin, can refuse an order or restrict
your account.

**Some changes on MarketAI close your positions.** When your bot is paused, is waiting for
MarketAI's approval, is not paid, or its signal feed is withdrawn, and when MarketAI
reports a state the connector does not recognise, the connector closes every open
position (at market when a limit order does not fill), then waits. When you move a bot to
another signal feed, it first closes the old feed's positions. A close can lock in a loss.
For example: you hold BTC long at 3x, and your payment fails when BTC is 5% below your
entry. The connector closes at market, and you lose about 15% of the money in that
position, plus fees. On Alpaca, these cases do not close positions: the connector sells at
market, at once or at the next open, every share the account holds in the bot's markets,
and buys nothing; a move to another rule feed sells only the old feed's markets that the
new feed does not trade. When the bot is deleted or its token is replaced, the connector
stops trading and leaves open positions as they are, each with the stop-loss already
placed for it at the exchange, if it has one (on Alpaca, the connector keeps it while it
runs).

**The connector updates itself.** A new release is installed automatically, usually within
a quarter of an hour, unless you turn automatic updates off. A new release can change how
the connector behaves. What each release changes is in the release notes:
https://github.com/sergimes/marketai-connector/releases.

**The software can have bugs.** It comes as it is: see [LICENSE](LICENSE) sections 9 and
10, which also say which rights you keep as a consumer. Use an API key that **cannot
withdraw** where the exchange offers one, start with a **demo account** (on Alpaca, a
paper account) and then with an amount you can afford to lose, and check your exchange
account yourself.

**You are responsible for your account.** You run the connector on your computer, with your
exchange account and your API keys. You are responsible for keeping those keys safe, and for
following the laws where you live; some countries restrict leveraged derivatives trading,
or investing with borrowed money, for retail customers.

**Characteristics you accept separately.** The connector is made to work this way, which
may differ from what you would expect of trading software. The setup asks you to accept
each of these characteristics with a second, separate yes:
- on a crypto exchange, it acts on each signal once, when it arrives, and never replays a
  signal missed while it was not running or not connected; on Alpaca, it applies only the
  latest target portfolio, while the market is open;
- a take-profit rests on the order book as a limit order and can be missed;
- a stop-loss fires at market and can fill worse than its trigger price;
- it closes positions at market in the cases listed in LICENSE section 8.3, and on
  Alpaca sells them at market in the cases listed in section 8.5;
- on Alpaca, it sells at market to follow the target portfolio; it buys what the feed
  buys at the open with a market order shortly after the open, at any price, and
  anything else the account is short of only at or below the price limit MarketAI sends,
  so the account can hold less than its target portfolio;
- on Alpaca, it treats every share the account holds in the bot's markets as the bot's,
  whoever bought it;
- on Alpaca, a stop-loss fires only while the market is open, and a fraction of a share
  carries only its stop-loss, for one trading day, placed again each day while the
  connector runs;
- it updates itself, and an update can change how it trades.
