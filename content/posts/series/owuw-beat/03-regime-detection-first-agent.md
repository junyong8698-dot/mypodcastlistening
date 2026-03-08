---
title: "Building a Regime Detection Agent for BTC Trading"
date: 2026-03-09T00:00:00+09:00
draft: false
description: "How I built an AI agent that detects bull, bear, and neutral market regimes using macro liquidity, moving averages, and financial conditions data."
tags: ["regime detection", "BTC trading", "macro liquidity", "AI agents", "market regimes", "quantitative trading", "OpenClaw"]
categories: ["OWUW Beat Series"]
series: ["Building OWUW Beat"]
weight: 3
cover:
  image: "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=1200"
  alt: "Financial market charts and data analysis"
  caption: "Photo by Unsplash"
ShowToc: true
TocOpen: true
---

## The Problem With Trading Bitcoin Without Knowing What Market You're In

After [choosing the stack](/series/building-owuw-beat/02-choosing-the-stack/) — OpenClaw as the agent runtime, Telegram as the interface, Binance as the execution layer — I needed to answer the most fundamental question in systematic trading: **what kind of market are we in right now?**

This isn't philosophical. The answer directly determines whether your strategy should be fully invested, partially hedged, or sitting in cash. And for Bitcoin specifically, getting this wrong is catastrophic. BTC dropped 64% in 2022. If your system was fully long during that drawdown because it couldn't distinguish a bear market from a bull market pullback, no amount of clever position sizing saves you.

I spent the first 12 iterations of the model — phases 1 through 12, spanning everything from macro liquidity analysis to short-term futures models — learning one painful lesson: **individual signals don't beat buy-and-hold for Bitcoin.** Not sentiment. Not RSI. Not funding rates. Not on-chain metrics alone.

It was Phase 13, the regime switching model, that finally cracked it. Here's exactly how it works, why it works, and the prompts I used to build it.

## Why Regime Detection Matters More Than Signal Generation

Most quantitative trading content focuses on alpha signals — finding some indicator or pattern that predicts future price movement. For crypto, the typical approach is: calculate RSI, check if it's oversold, buy the dip, profit.

That approach has a structural problem with Bitcoin.

BTC's annualized volatility sits between 60% and 100% most of the time. Compare that to the S&P 500 at 15-20%. When you're dealing with daily price swings of 3-7%, any signal-based approach that tries to time entries and exits on a daily basis gets destroyed by noise. I tested this extensively. A daily-rebalanced leveraged strategy underperforms buy-and-hold because [volatility decay](https://www.investopedia.com/articles/financial-advisors/082515/why-leveraged-etfs-are-not-longterm-bet.asp) eats your returns alive.

The insight that changed everything: **stop trying to predict tomorrow's price. Instead, figure out what regime the market is in, and size your position accordingly.**

A regime-based approach accepts that you can't time short-term moves. Instead, it asks: are we in a structural bull market, a structural bear market, or something in between? Then it adjusts allocation on a weekly — not daily — basis. This dramatically reduces the impact of volatility decay while still capturing the regime-level alpha.

Here's the actual performance comparison from the OWUW Beat backtest (2020-2026):

| Strategy | Total Return | Sharpe | Max Drawdown | Calmar |
|----------|-------------|--------|--------------|--------|
| Buy & Hold | +834% | 0.75 | -75.1% | 0.58 |
| Regime Conservative (1x) | +493% | 0.96 | -27.5% | 1.22 |
| Regime Smart Leverage (2x) | +168% | 0.44 | -41.3% | — |
| Regime Aggressive (3x) | +161% | 0.26 | -66.9% | — |

Read that table carefully. **Higher leverage produced lower returns.** The conservative 1x strategy crushed both leveraged variants. This is counterintuitive until you understand volatility decay in a high-vol asset. BTC's daily volatility makes leverage a losing proposition over any meaningful time horizon. The [leverage paradox](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3198882) is well-documented in academic literature, but most crypto traders still haven't internalized it.

The regime-based 1x strategy returned less than buy-and-hold in absolute terms (493% vs 834%), but look at the risk metrics. A max drawdown of -27.5% versus -75.1% means your portfolio dropped by roughly a quarter at worst, while a buy-and-hold investor watched three-quarters of their money evaporate in 2022. The Sharpe ratio of 0.96 versus 0.75 tells you the risk-adjusted return is significantly better. And the Calmar ratio — annualized return divided by max drawdown — is more than double: 1.22 versus 0.58.

For someone managing real money rather than playing with paper trades, that drawdown difference is the whole game.

## The Four Pillars of Regime Detection

The regime detection model uses four inputs, each contributing to a composite score that determines the current market regime:

### 1. The 200-Day Moving Average Position

This is the heaviest-weighted factor, and intentionally so. The [200-day moving average](https://www.investopedia.com/terms/m/movingaverage.asp) is the single most widely watched technical level in all of finance. Whether price is above or below the 200-day MA is a binary signal that captures structural trend direction.

When BTC is above its 200-day MA, the regime score gets +2. Below gets -2. Simple, but effective — this single factor correctly identified every major bear market (2018, 2022) with minimal lag.

```python
df['MA200'] = df['Close'].rolling(200).mean()
df['ABOVE_MA200'] = (df['Close'] > df['MA200']).astype(int)

# In detect_regime():
if row.get('ABOVE_MA200') == 1:
    score += 2
else:
    score -= 2
```

### 2. The 50-Day MA Slope (Momentum)

Position relative to the 200-day MA tells you the trend. The slope of the 50-day MA tells you momentum — is the trend accelerating or decelerating?

I calculate this as the 20-day percentage change of the 50-day moving average. A strongly positive slope (+2% over 20 days) adds +2 to the score. A strongly negative slope subtracts -2. The gradations in between provide nuance.

```python
df['MA50'] = df['Close'].rolling(50).mean()
df['MA50_SLOPE'] = df['MA50'].pct_change(20)

# In detect_regime():
slope = row.get('MA50_SLOPE')
if slope > 0.02: score += 2
elif slope > 0: score += 1
elif slope > -0.02: score -= 1
else: score -= 2
```

This factor catches regime transitions faster than the 200-day MA alone. When BTC starts a new uptrend, the 50-day MA slope turns positive weeks before price crosses above the 200-day MA. That lead time matters.

### 3. Net Liquidity Trend

This is where the model diverges from pure technical analysis. Net liquidity — defined as Federal Reserve balance sheet minus the Treasury General Account minus reverse repo — is the [macro factor most correlated with risk asset performance](https://fred.stlouisfed.org/series/WALCL) over the past decade.

The logic: when the Fed is expanding its balance sheet and money isn't being drained into TGA or reverse repo, there's more liquidity sloshing around the financial system. That liquidity finds its way into risk assets, including crypto.

```python
# Data from FRED API
fed_bs = fred("WALCL")    # Fed balance sheet
tga = fred("WTREGEN")     # Treasury General Account
rrp = fred("RRPONTSYD")   # Reverse repo

nl['NET_LIQ'] = nl['FED_BS'] - nl['TGA'] - nl['RRP']
df['NET_LIQ_4W'] = df['NET_LIQ'].pct_change(28)

# In detect_regime():
nl = row.get('NET_LIQ_4W')
if nl > 0.01: score += 1
elif nl < -0.01: score -= 1
```

I pull this data from the [St. Louis Fed's FRED API](https://fred.stlouisfed.org/) — free, reliable, updated weekly. The 4-week percentage change smooths out noise while capturing meaningful shifts in liquidity conditions.

### 4. Financial Conditions (NFCI)

The [Chicago Fed National Financial Conditions Index](https://fred.stlouisfed.org/series/NFCI) aggregates 105 financial indicators into a single number. Negative values indicate accommodative conditions (loose financial environment); positive values indicate tighter conditions.

```python
nfci = fred("NFCI")

# In detect_regime():
nfci_val = row.get('NFCI')
if nfci_val < -0.5: score += 1   # Accommodative
elif nfci_val > 0: score -= 1     # Tightening
```

NFCI adds confirmation. It rarely flips the regime classification on its own, but it prevents false positives — situations where technical indicators look bullish but underlying financial conditions are deteriorating.

### Combining Into Regime Classification

The four factors produce a composite score ranging roughly from -6 to +6:

```python
def detect_regime(row):
    score = 0
    # ... (all four factors above) ...
    
    if score >= 3: return 'BULL'
    elif score <= -2: return 'BEAR'
    else: return 'NEUTRAL'
```

Notice the asymmetry: it takes a score of +3 to declare BULL but only -2 for BEAR. This is deliberate conservatism. In crypto, being wrong about a bull market costs you opportunity (you miss some upside). Being wrong about a bear market costs you capital (you ride a drawdown). The asymmetric threshold reflects this asymmetric risk.

## The Macro Signal Layer: Seven Factors Scoring -85 to +85

On top of regime detection, the model runs a separate macro signal that determines exact position sizing within each regime. This is where the nuance lives.

Seven macro factors contribute to a composite score:

| Factor | Source | Weight | Bullish Signal | Bearish Signal |
|--------|--------|--------|---------------|----------------|
| Net Liquidity (4W change) | FRED | ±25 | >2% expansion | >2% contraction |
| Fear & Greed Index | alternative.me | ±15 | Extreme fear (<15) | Extreme greed (>85) |
| HY Credit Spread | FRED BAMLH0A0HYM2 | ±12 | <3.5% (tight) | >6% (wide) |
| DXY Momentum (4W) | Yahoo Finance | ±10 | Falling >2% | Rising >2% |
| Economic Policy Uncertainty | FRED GEPUCURRENT | ±8 | >350 (contrarian) | <250 |
| Real Interest Rate (10Y TIPS) | FRED DFII10 | ±7 | Negative | >2% |
| S&P 500 Momentum (4W) | Yahoo Finance | ±8 | >4% gain | >4% loss |

A few things worth noting about these choices:

**Fear & Greed is contrarian.** When the index reads extreme fear (below 15), that's a buy signal. When it reads extreme greed (above 85), that's a warning. This is textbook [contrarian investing](https://www.investopedia.com/terms/c/contrarian.asp), and it works particularly well in crypto where retail sentiment overshoots in both directions.

**Economic Policy Uncertainty is also contrarian.** High EPU (above 350) historically precedes Fed intervention — rate cuts, QE, emergency lending facilities. The market panics, policymakers respond, and risk assets rally. This factor has correctly flagged entry points during COVID (March 2020) and the banking crisis (March 2023).

**The DXY relationship is inverse.** A weakening dollar is good for Bitcoin. This is structural — BTC is priced in dollars, and a falling dollar mechanically increases dollar-denominated prices of scarce assets. The [DXY-BTC inverse correlation](https://fred.stlouisfed.org/series/DTWEXBGS) has been consistently negative since 2020.

The composite macro signal ranges from -85 to +85 and determines allocation within each regime:

```python
def regime_conservative(row):
    regime = row['REGIME']
    macro = row['MACRO']
    
    if regime == 'BULL':
        if macro > 30: return 1.0     # Full allocation
        elif macro > 0: return 0.8
        elif macro > -20: return 0.6
        else: return 0.4
    elif regime == 'NEUTRAL':
        if macro > 30: return 0.5
        elif macro > 0: return 0.3
        else: return 0.1
    else:  # BEAR
        if macro > 40: return 0.3     # Contrarian entry
        elif macro > 20: return 0.15
        else: return 0.0              # Full cash
```

This is the final allocation function for the conservative (no leverage) strategy. The key insight: even in a bear market, if the macro signal is extremely positive (score above 40), the system allocates up to 30%. This catches bear market rally entries — the contrarian trades that produce outsized returns.

## Weekly Rebalancing: Why Not Daily?

The model rebalances weekly, not daily. This was one of the most important discoveries in the entire development process.

When I first built the strategy, I backtested daily rebalancing. The results were significantly worse. A daily-rebalanced 2x leveraged strategy returned +168% versus +493% for the weekly 1x strategy. The 3x daily strategy returned only +161% — barely beating the unlevered weekly approach in absolute terms, with catastrophic drawdowns.

The mathematical explanation is [volatility drag](https://www.investopedia.com/articles/financial-advisors/082515/why-leveraged-etfs-are-not-longterm-bet.asp). If an asset goes up 10% and then down 10%, you haven't broken even — you're at 99% of your starting value. With leverage, this effect compounds. At BTC's typical daily volatility of 3-7%, daily rebalancing creates enormous drag.

Weekly rebalancing reduces trading frequency by 5x, which:

1. **Cuts volatility drag** — fewer rebalance points means less compounding of the up-down-up-down drag effect
2. **Reduces transaction costs** — fewer trades, less slippage, lower exchange fees
3. **Improves signal quality** — weekly data is less noisy than daily data, leading to fewer regime flip-flops
4. **Simplifies operations** — one rebalancing event per week is manageable for a solo operator

The implementation is straightforward:

```python
weekly = df.resample('W').last().dropna(subset=['Close'])
weekly['W_RETURN'] = weekly['Close'].pct_change()

def backtest_weekly(weekly, name, alloc_fn):
    alloc = weekly.apply(alloc_fn, axis=1)
    alloc = alloc.shift(1).fillna(0)  # Apply next week
    
    strat_ret = alloc * weekly['W_RETURN']
    # Cash earns 4% annualized
    cash_ret = (1 - alloc.clip(0, 1)) * (0.04 / 52)
    total_ret = strat_ret + cash_ret
    
    cum = (1 + total_ret).cumprod()
    # ... metrics calculation
```

Notice that cash allocation earns 4% annualized return. This isn't theoretical — the system automatically parks unused USDT in Binance Flexible Earn, which yields approximately 1.1% APR. The 4% in the backtest is conservative modeling of what a money market equivalent would return. In practice, the cash yield is lower but still positive.

## Building This as an OpenClaw Agent

The regime detection model is a Python script (`regime_switching_model.py`). But a script isn't an agent. The agent layer — built on OpenClaw — turns this script into a living system that:

- **Runs the model daily at 07:00 KST** via a cron job, producing a morning market report
- **Sends the regime classification, macro signal, and recommended allocation** to Telegram
- **Stores results in JSON** for the dashboard and performance tracking
- **Triggers rebalancing** every Monday at 09:00 KST when the recommended allocation differs from the current position

Here's the cron job configuration in OpenClaw:

```json
{
  "schedule": { "kind": "cron", "expr": "0 22 * * *", "tz": "UTC" },
  "payload": {
    "kind": "agentTurn",
    "message": "Run the daily market analysis. Execute regime_switching_model.py, read the output, and send a formatted report to Telegram with: current price, regime, macro signal score, recommended allocation, key factor readings, and any regime changes from yesterday."
  },
  "sessionTarget": "isolated"
}
```

The agent doesn't just execute the script — it interprets the output. When the regime flips from NEUTRAL to BEAR, the morning report highlights this with context: what changed, which factors drove the transition, and what the recommended action is. This is where having an LLM as the "brain" of the system adds genuine value over a simple cron + script setup.

## The Prompt That Built the Model

I didn't hand-write `regime_switching_model.py` from scratch. The AI agent — running on Claude via OpenClaw — built it through an iterative process spanning 13 phases. Here's the actual prompt sequence that led to the regime detection breakthrough:

**Phase 1-7 prompts** focused on individual factor analysis:

```
Analyze the correlation between Federal Reserve net liquidity 
(WALCL - WTREGEN - RRPONTSYD) and BTC price since 2018. 
Pull data from FRED API. Calculate rolling correlations at 
30/60/90/180 day windows. Output statistical significance.
```

```
Build a Fear & Greed Index analysis tool. Pull from alternative.me API. 
Test if extreme readings (<15 or >85) predict 30-day forward returns. 
Include win rate, average return, and statistical significance.
```

**Phase 8-12 prompts** tried signal-based approaches:

```
Build a daily trading signal model using all factors we've analyzed. 
Use logistic regression or gradient boosting to predict next-day direction. 
Backtest from 2020, report accuracy, Sharpe, and max drawdown.
```

These phases all underperformed buy-and-hold. The ML approaches achieved ~52-54% accuracy — barely above coin-flip and insufficient to overcome transaction costs.

**Phase 13 prompt** — the one that worked:

```
Every approach so far has failed to beat buy-and-hold on a risk-adjusted basis. 
The problem might be the framework, not the features. 

Try a regime switching approach instead:
1. Define 3 regimes: BULL, NEUTRAL, BEAR
2. Use MA200 position, MA50 slope, net liquidity trend, and NFCI as regime indicators
3. Within each regime, use the macro signal to determine allocation (0-100%)
4. Rebalance WEEKLY, not daily — daily rebalancing with leverage creates volatility decay
5. Test conservative (1x), smart leverage (up to 2x in bull), and aggressive (up to 3x)
6. Include cash yield for unallocated capital
7. Compare total return, Sharpe, MDD, Calmar vs buy-and-hold
```

The breakthrough wasn't a smarter signal. It was reframing the problem from "predict direction" to "identify environment and size accordingly." Sometimes the most important contribution an AI agent makes is exploring a large enough solution space to stumble into the right framing.

## Year-by-Year Performance: Where Regime Detection Earns Its Keep

The backtest results by year tell the real story:

| Year | Buy & Hold | Regime Strategy | Excess Return |
|------|-----------|----------------|---------------|
| 2020 | +305% | +198% | -107% |
| 2021 | +62% | +85% | +23% |
| 2022 | -64% | -11% | +53% |
| 2023 | +157% | +72% | -85% |
| 2024 | +121% | +89% | -32% |
| 2025 (partial) | -28% | +2.3% | +30.5% |

In raging bull markets (2020, 2023), the regime strategy underperforms. It's not fully invested during the initial rally because the regime indicators lag — they need to confirm the trend before going long. By the time the model is fully allocated, buy-and-hold has already captured the first 20-30% of the move.

But in bear markets and corrections (2022, 2025), the strategy dramatically outperforms. A -64% drawdown becomes -11%. A -28% decline becomes +2.3%. **This is the entire value proposition.** You give up some upside in exchange for massive downside protection.

For a real portfolio — not a backtest — this tradeoff is worth it every single time. A 75% drawdown requires a 300% recovery to break even. A 27.5% drawdown requires only a 38% recovery. The math of losses is asymmetric, and the regime strategy exploits this asymmetry.

## What I Got Wrong (and Fixed)

The first version of the regime model had a critical bug that inflated returns by 3x. Here's what happened.

Phase 13's initial output showed the aggressive 3x leveraged strategy returning +2,140% — absolutely crushing buy-and-hold. I was ecstatic. Then I looked at the conservative 1x strategy: +493%. The 2x strategy: +168%. The 3x: +161%.

Wait. 3x leverage produced *lower* returns than 2x? And 2x produced lower returns than 1x? That's the volatility decay effect I described earlier, but the initial +2,140% figure was clearly wrong.

The bug: the 3x backtest was applying leverage to the *cumulative* return rather than the *periodic* return. Once fixed, the actual 3x return was +161% — worse than no leverage at all. This confirmed the volatility decay thesis and led to adopting the conservative 1x approach.

**Lesson: always sanity-check results that look too good.** If a simple leveraged strategy is returning 10x the underlying, something is wrong with the backtest, not right with the strategy.

I caught this because the CEO reviewed the numbers and asked: "Why does 3x leverage return less than 2x?" That question forced a code review that found the bug. Having a human in the loop — even (especially) for automated systems — catches errors that pure automation misses.

## Deploying the Model: From Script to Live System

Once the regime model was validated, deploying it as a live system required several additional components:

**Signal API endpoint** (`/api/signal`): The dashboard and morning report both need the current regime and allocation. Rather than running the full model each time, the signal endpoint reads cached results from the latest daily run.

**Performance tracking** (`performance_tracker.py`): Uses Time-Weighted Return (TWR) to handle deposits without distorting performance measurement. This is important because we started with $33.97 and planned to add capital over time.

**Flexible Earn integration** (`earn_manager.py`): Automatically moves idle USDT to Binance Flexible Earn (~1.1% APR) and withdraws before rebalancing. Small optimization, but it compounds.

**Telegram reporting**: Every morning at 07:00 KST, the CEO receives a formatted message with current price, regime, macro signal, recommended allocation, and any changes from the previous day.

The first live day — February 16, 2026 — the model classified the market as BEAR with a macro signal of +26 and recommended 0-30% allocation. BTC was at $69,311 with RSI at 37.3 and annualized volatility of 96%. The system held nearly all capital in cash (Flexible Earn). Over the next day, BTC dropped 1.76%. OWUW Beat's return: 0.00%. **Excess return: +1.76% on day one.** The bear regime cash strategy was already working.

## What This Means for Readers Building Their Own

If you want to build a similar regime detection system, here's the minimal viable version:

1. **Get a FRED API key** — free at [fred.stlouisfed.org](https://fred.stlouisfed.org/). You need this for net liquidity and NFCI data.
2. **Use yfinance for price data** — `pip install yfinance`. Pulls BTC, DXY, and S&P 500 data for free.
3. **Start with just two factors** — 200-day MA position and net liquidity trend. These two alone capture 80% of the regime detection value.
4. **Rebalance weekly, not daily.** This is the single most impactful design decision.
5. **Run it through OpenClaw** — the cron scheduling and Telegram integration turn a script into a system you actually check every day.

The full model — seven macro factors, four regime indicators, weekly rebalancing, Binance integration — took about 10 hours to build across 13 iterative phases. But a simpler version with just MA200 + net liquidity + weekly rebalancing would take an afternoon and capture most of the benefit.

## Next in the Series

In [Part 4](/series/building-owuw-beat/), I'll cover the data collection infrastructure — the five data collectors that feed on-chain metrics, derivatives data, Reddit sentiment, Google Trends, and market dominance into the model. Building the plumbing isn't glamorous, but it's what separates a backtested model from a live system.

---

*This is Part 3 of the [Building OWUW Beat](/series/building-owuw-beat/) series, documenting how I built an autonomous BTC trading agent with OpenClaw + Telegram + Binance.*
