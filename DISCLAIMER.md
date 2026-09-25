# Risk disclaimer

Read this before you run the MarketAI Connector with real money. En español:
[DISCLAIMER.es.md](DISCLAIMER.es.md).

**You can lose money, including more than you expect.** The connector trades perpetual
futures with leverage. When the price moves against a leveraged position, you lose a
multiple of that move: at 3x leverage, a 10% move against you loses you about 30% of the
money in that position. With cross margin, a large enough loss can take your whole
account balance.

**Signals are not personal advice.** MarketAI's signal feeds come from statistical models.
Everyone who follows a feed gets the same signals, whatever their situation. We do not
check whether this trading suits you, your money or your experience. Backtests and past
live results do not predict future results. A feed can lose money for long periods.

**Every order is yours.** The signals come from MarketAI; the choice to follow them
automatically is yours. Once you start the connector, it places, changes and cancels
orders on your account by itself, without asking you first. By running it, you authorise
those orders, and they and their results are yours, whatever caused them. If a failure of
the connector or of MarketAI's service causes you a loss, LICENSE section 10 says whether
we must compensate you: if you use the connector for a business, we do not, except for
wilful misconduct or gross negligence; if you are a consumer, we do so as the law
provides, and no further. Check your exchange account regularly, and stop the connector
at once if you see an order you did not expect. To stop it trading, pause your bots on My
bots, which closes their positions, or stop the connector, which leaves them open with
their stop-loss and take-profit.

**Orders do not always fill as planned.** A stop-loss fires as a market order and can fill
worse than its trigger price in a fast market. A take-profit rests on the order book as a
limit order and can be missed when the price only touches it. Exchanges, networks,
MarketAI and your own computer can fail or be slow, and a signal sent while the connector
is offline is not sent again.

**Some changes on MarketAI close your positions.** When your bot is paused, is waiting for
MarketAI's approval, is not paid, or its signal feed is withdrawn, and when MarketAI
reports a state the connector does not recognise, the connector closes every open
position (at market when a limit order does not fill), then waits. When you move a bot to
another signal feed, it first closes the old feed's positions. A close can lock in a loss.
For example: you hold BTC long at 3x, and your payment fails when BTC is 5% below your
entry. The connector closes at market, and you lose about 15% of the money in that
position, plus fees. When the bot is deleted or its token is replaced, the connector stops
trading and leaves open positions as they are, each with the stop-loss already placed for
it at the exchange.

**The connector updates itself.** A new release is installed automatically, usually within
a quarter of an hour, unless you turn automatic updates off. A new release can change how
the connector behaves. What each release changes is in the release notes:
https://github.com/sergimes/marketai-connector/releases.

**The software can have bugs.** It comes as it is: see [LICENSE](LICENSE) sections 9 and
10, which also say which rights you keep as a consumer. Use an API key that **cannot
withdraw**, start with a **demo account** and then with an amount you can afford to lose,
and check your exchange account yourself.

**You are responsible for your account.** You run the connector on your computer, with your
exchange account and your API keys. You are responsible for keeping those keys safe, and for
following the laws where you live; some countries restrict leveraged derivatives trading
for retail customers.

**Characteristics you accept separately.** The connector is made to work this way, which
may differ from what you would expect of trading software. The setup asks you to accept
each of these characteristics with a second, separate yes:
- it acts on each signal once, when it arrives, and never replays a signal missed while
  it was not running or not connected;
- a take-profit rests on the order book as a limit order and can be missed;
- a stop-loss fires at market and can fill worse than its trigger price;
- it closes positions at market in the cases listed in LICENSE section 8.3;
- it updates itself, and an update can change how it trades.
