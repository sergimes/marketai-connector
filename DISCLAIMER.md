# Risk disclaimer

Read this before you run the MarketAI Connector with real money.

**You can lose money, including more than you expect.** The connector trades perpetual
futures with leverage. A move against a leveraged position loses a multiple of that move.
With cross margin, a large enough loss can take your whole account balance.

**Signals are not advice.** MarketAI's signal feeds are the output of statistical models.
They are not investment advice, and nothing here is a recommendation to buy or sell
anything. Backtests and past live results do not predict future results. A feed can lose
money for long periods.

**Orders do not always fill as planned.** A stop-loss fires as a market order and can fill
worse than its level in a fast market. A take-profit rests as a limit order and can be
missed when the price only touches it. Exchanges, networks, MarketAI and your own computer
can fail or be slow, and a signal sent while the connector is offline is not sent again.

**Some changes on MarketAI close your positions.** When your bot is paused, its signal
feed is withdrawn, or it is not paid, the connector closes every open position (at market
when a limit order does not fill), then waits. When the bot is deleted or its token is
replaced, the connector stops trading and leaves open positions as they are, each with its
stop-loss.

**The connector updates itself.** A new release is installed automatically, usually within
a quarter of an hour, unless you turn automatic updates off. A new release can change how
the connector behaves.

**The software can have bugs.** It is provided as is, without warranty of any kind (see
[LICENSE](LICENSE)). Use an API key that **cannot withdraw**, start with a **demo account**
and then with an amount you can afford to lose, and check your exchange account yourself.

**You are responsible for your account.** You run the connector on your computer, with your
exchange account and your API keys. You are responsible for keeping those keys safe, for
the orders placed on your account, and for following the laws where you live; some
countries restrict leveraged derivatives trading for retail customers.
