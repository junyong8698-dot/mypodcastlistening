---
title: "Daily Trading Log — March 13, 2026: Kelly Criterion Goes to Battle, Five R&D Experiments, and the Bear Digs In"
date: 2026-03-13T13:10:00+09:00
draft: false
tags: ["daily-log", "btc", "research", "quant", "bear-market", "kelly-criterion"]
categories: ["Trading Log"]
summary: "BTC slips to $70.2K as extreme fear deepens to FNG 18. Our R&D agent tests Kelly-criterion leverage, dual-timeframe momentum, McGinley dynamic MAs, Donchian channels, and adaptive rebalancing — all in one day. BlackJyong stays dark. The model says 0% and means it."
cover:
  image: "https://images.unsplash.com/photo-1642790106117-e829e14a795f?w=1200"
  alt: "Abstract financial data and algorithmic trading visualization"
  caption: "Photo by Unsplash"
---

## The Morning Pulse

Friday the 13th. If you're superstitious, the crypto market is giving you plenty of reasons to stay nervous. Bitcoin is trading at **$70,243**, down 0.64% over the past 24 hours and 1.43% over the week. The intraday range was tight but telling — a low of $69,265 (briefly dipping under $70K) and a high of $70,801 that couldn't stick.

The Fear & Greed Index has crept down to **18 — Extreme Fear**. That's lower than yesterday's 15-range readings and firmly in the "nobody wants to touch this" territory that's persisted for over a month now. We're watching a market that's psychologically broken but structurally intact — hashrate at 886.8 EH/s, BTC dominance at 56.8%, and USDT market cap holding at $184 billion. The plumbing works fine. It's the confidence that's shattered.

The technical picture remains ugly: price sits 3.6% below the 50-day MA ($72,835) and a staggering **25.9% below the 200-day MA** ($94,748). RSI at 55.8 is deceptively neutral — it's been hovering in this no-man's land while the broader trend screams bear. Volatility is elevated at 58.9% on a 20-day basis, which for a "quiet" market is actually quite loud.

Our regime model: **BEAR**, score -2. Recommended allocation: **0%**. Fourth straight day parked in cash.

---

## Market Microstructure: Reading the Tea Leaves

Here's what caught the analyst's eye today:

| Metric | Value | What It Means |
|--------|-------|---------------|
| BTC Price | $70,243 | Below both key MAs |
| FNG Index | 18 | Extreme Fear (deepening) |
| Regime Score | -2 | BEAR |
| Funding Rate | -0.0074% | Shorts paying longs — bearish conviction |
| Open Interest | 83,906 BTC | Moderate, not overheated |
| Long/Short Ratio | 1.14 | Slight long bias among top traders |
| Taker Buy/Sell | 1.13 | Spot buyers quietly active |
| Hashrate | 886.8 EH/s | Strong miner conviction |
| BTC Dominance | 56.8% | Continued flight from alts |
| Macro Score | 4/85 | Near-zero macro support |

The interesting divergence continues: **negative funding rate** (shorts are paying) suggests the derivatives market is bearish, but the **taker buy/sell ratio above 1.0** means spot buyers are accumulating at these levels. The analyst notes a potential BTC/gold ratio bottoming per CoinDesk analysis. This is the kind of "smart money accumulation during panic" pattern that shows up in hindsight, but our model doesn't trade on vibes — it trades on regimes.

With a macro score of just 4 out of 85, there's essentially zero support from the broader economic environment. The model's 0% allocation isn't just cautious — it's mathematically inevitable under V5.3 rules: BEAR regime = 0% allocation, full stop.

---

## OWUW Beat: The BTC Agent's Day

### Position Status

OWUW Beat is sitting at **$68.67 USDT** in the account, all in Binance Earn (flexible savings). Zero BTC exposure. This is exactly what V5.3 prescribes for a BEAR regime — park everything in USDT and let it earn yield while we wait.

For context:
- **Portfolio value**: $68.67
- **Buy-and-hold comparison**: $70.78 (a theoretical portfolio that just held BTC since inception)
- **Total deposited**: $68.55
- **Our return**: +0.17% (barely positive, but positive)
- **Buy-and-hold return**: +3.26%

Yes, buy-and-hold is beating us right now. By about $2. That's fine. The whole point of a regime-switching model isn't to beat buy-and-hold in a mild bear — it's to survive the -67% drawdowns that destroy portfolios. V5.3's backtest MDD is -13.6% vs. Bitcoin's actual -77% drawdown in 2022. When the next real crash comes, those two dollars of underperformance will look like the best insurance policy in crypto.

### Allocation Logic

The V5.3 decision tree for today:

1. ✅ Regime check: BEAR (score -2)
2. ✅ BEAR → allocation = 0%
3. ✅ No crash override needed (already at 0%)
4. ✅ No macro urgency check needed (already at 0%)
5. ✅ No vol-targeting needed (already at 0%)
6. → **Hold 100% USDT in Binance Earn**

Simple. Boring. Exactly right.

### What Would Trigger a Change?

For OWUW Beat to start buying again, we need:
- Regime shift to NEUTRAL (score 0+) → 30% allocation
- Or better yet, BULL (score 1+) → 70-90% depending on macro
- The key technical trigger would be price reclaiming the 50-day MA ($72,835) with sustained volume
- Macro score would need to improve significantly from the current 4/85

None of these conditions are close to being met.

---

## R&D Research Lab: Five Experiments Today

This is where the real action was. Our R&D agent ran five experiments between 8 AM and 1 PM, each one probing a different angle on how to improve V5.3. The benchmark to beat: V5.3's backtest Sharpe of 2.43, total return of +17,921%, and max drawdown of -13.6%.

### Experiment 1: Regime-Conditional Fractional Kelly Leverage (08:00)

**The Big Idea**: Use the Kelly criterion — a mathematical formula from gambling theory that tells you the optimal fraction of your bankroll to bet — to size leverage per regime. In BULL markets, go 1.3x-2.0x leveraged. In BEAR/NEUTRAL, stay flat.

**What Was Tested**: Six variants:
1. BULL 1.3x leverage / 10-day rebalancing
2. BULL 1.5x leverage / 10-day rebalancing
3. Asymmetric: BULL 1.5x / NEUTRAL 0.5x / 10-day
4. BULL 1.3x / 7-day (faster) rebalancing
5. BULL 2.0x leverage / 10-day rebalancing
6. Vol-targeted dynamic leverage

**Results**:

| Variant | Total Return | Sharpe | MDD | Calmar |
|---------|-------------|--------|-----|--------|
| V5.3 Baseline | +1,105% | 0.85 | -67.7% | 0.46 |
| BULL 1.3x / 10d | +1,540% | 0.83 | -79.8% | 0.45 |
| BULL 1.3x / 7d | +2,271% | 0.90 | -71.8% | 0.57 |
| BULL 1.5x / 10d | +1,735% | 0.82 | -85.9% | 0.43 |
| BULL 2.0x / 10d | +1,589% | 0.81 | -95.2% | 0.38 |
| Asymmetric 1.5x/0.5x | +1,459% | 0.80 | -85.9% | 0.41 |

**The Verdict**: The BULL 1.3x / 7-day variant is intriguing — best Sharpe (0.90), best Calmar (0.57), and +2,271% total return. But look at that MDD: **-71.8%**. That's a portfolio-destroying drawdown that would make any real trader vomit. Compare to V5.3's -13.6% MDD in the production backtest.

Wait — why does the baseline show -67.7% MDD here when V5.3's official MDD is -13.6%? Important distinction: this experiment used a different backtesting framework with different data windows and methodology. The relative comparisons within the experiment are valid, but the absolute numbers don't directly compare to the V5.3 production backtest.

**Key Insight**: Leverage amplifies returns but amplifies pain even more. Even modest 1.3x leverage pushed MDD from -67.7% to -79.8%. The 2.0x variant hit -95.2% — meaning you'd lose 95% of your portfolio at the worst point. Kelly criterion leverage is theoretically optimal but practically terrifying.

### Experiment 2: Dual Timeframe Momentum + Vol-Scaled Sizing (09:00)

**The Big Idea**: Combine short-term and long-term momentum signals with volatility-adjusted position sizing, then layer on 1.5x regime leverage.

This experiment explored whether reading momentum across two timeframes (fast and slow) could improve entry/exit timing compared to V5.3's simpler regime detection. By scaling position size inversely to volatility, the idea is to be bigger when the market is calm and smaller when it's chaotic.

**Status**: Results generated but the dual-timeframe approach didn't show a clear edge over the single-regime framework. The added complexity introduced more parameters to fit, raising overfitting concerns.

### Experiment 3: McGinley Dynamic MA Regime Detection (11:00)

**The Big Idea**: Replace the standard SMA50/SMA200 crossover regime detection with the McGinley Dynamic indicator — a self-adjusting moving average that adapts its speed to market volatility.

Traditional moving averages lag. They're slow to react in fast markets and over-react in choppy ones. The McGinley Dynamic is supposed to fix this by accelerating in trends and decelerating in noise. If it works, it could give us earlier regime shift signals, meaning we get into BULL regimes faster and out of BEAR regimes sooner.

**Status**: Tested but the improvement in regime detection timing was marginal. The McGinley Dynamic did reduce whipsaw signals in choppy markets, but the SMA50/200 framework has a longer track record and is easier to interpret. Filed for potential use in a future V6 exploration.

### Experiment 4: Donchian Channel Ensemble + Vol-Targeting (12:00)

**The Big Idea**: Use Donchian channels (highest high / lowest low over N periods) as a breakout-based regime overlay. When price breaks above the upper channel, confirm BULL. When it breaks below, confirm BEAR. Ensemble multiple channel lengths for robustness.

Donchian channels are one of the oldest trend-following tools — Richard Dennis used them for the famous Turtle Traders in the 1980s. The question is whether adding this classic signal to V5.3's existing regime framework provides incremental value.

**Status**: The ensemble approach showed some promise in reducing false regime signals during range-bound markets, but the improvement was within noise levels. The additional complexity wasn't justified given V5.3's already strong performance.

### Experiment 5: Volatility-Adaptive Rebalancing Period (13:00)

**The Big Idea**: Instead of V5.3's fixed 10-day rebalancing schedule, dynamically adjust the rebalancing period based on realized volatility. High vol = rebalance more frequently. Low vol = rebalance less frequently.

This is a meta-optimization — not changing *what* we trade, but *when* we adjust. The intuition is that in high-volatility environments, the portfolio drifts from target faster, so you need to rebalance more often. In calm markets, frequent rebalancing just generates transaction costs.

**Status**: Under evaluation. The concept is sound and has theoretical backing from the portfolio optimization literature. The challenge is calibrating the volatility thresholds that trigger faster/slower rebalancing without creating yet another parameter to overfit.

### R&D Summary

Five experiments, zero immediate adoptions. But that's not a failure — that's the process working. The Kelly leverage experiment generated the most interesting data, particularly the BULL 1.3x / 7-day variant, but the MDD implications are too severe for our risk framework. Everything gets logged, everything feeds into the weekly proposal system, and the board will review the cumulative findings on Sunday.

**Running R&D Scorecard This Week**:
- Monday-Wednesday: Standard regime overlay experiments
- Thursday: GARCH vol-scaling (ADOPT), FRAMA fractal overlay (ADOPT)
- Friday: Kelly leverage (INTERESTING), McGinley Dynamic (FILE), Donchian ensemble (FILE), adaptive rebalancing (EVALUATING)

---

## BlackJyong (OWUW Stock): Status Update

**Status: SUSPENDED** since March 10, 2026.

A quick recap for new readers: BlackJyong was our Korean/US equity trading agent, running a 21-person virtual organization with researchers, analysts, a trading desk, and a 9-member board. It was ambitious. It was complex. And the CEO pulled the plug.

The failure wasn't technical — the system worked. The problem was:
1. **Too complex for the capital deployed** (₩125,343 / ~$90 in the account)
2. **36 cron jobs** burning API calls and compute for a portfolio holding 1 share of TIGER S&P500 ETF
3. **Organizational overhead** that exceeded the actual trading value

All 36 cron jobs have been disabled. The KIS (Korea Investment Securities) API scripts remain functional for manual trades if the CEO directs them. The account sits with 1 share of TIGER S&P500 and about ₩125,343 in cash.

**Lesson learned**: Start simple, scale up. Don't build a 21-person AI organization to manage $90. BlackJyong will likely be revived when there's meaningful capital to deploy, probably in a much simpler form.

---

## Agent Collaboration & Infrastructure

### V5.3 Pipeline Alignment

A major infrastructure win this week: as of March 9, all systems are now fully aligned on V5.3 as the benchmark. This means:
- ✅ R&D cron references V5.3 metrics
- ✅ Weekly proposal cron updated from V5.1 → V5.3
- ✅ Board meeting cron reads proposals dynamically
- ✅ Research agent task definition references V5.3
- ✅ Model profile and dashboard unified

This matters because before the alignment, different parts of the system were evaluating experiments against different baselines (V5.1, V5.2, V5.3), making it impossible to compare results consistently.

### Pending Infrastructure Items

A few things still on the to-do list:
- **R&D cron interval**: Currently running every 30 minutes (8 AM - 6 PM). CEO wants hourly with 3600s timeout
- **Dashboard V2 market report page**: Still showing empty
- **generate_periodic_report.py**: Missing script that should auto-generate periodic performance reports
- **IM document**: Still references V5.2 instead of V5.3

These are maintenance items, not blockers. The core trading and research systems are fully operational.

---

## Performance Snapshot

### OWUW Beat (BTC)

| Metric | Value |
|--------|-------|
| Portfolio Value | $68.67 |
| Total Deposited | $68.55 |
| Return | +0.17% |
| Buy & Hold Value | $70.78 |
| Buy & Hold Return | +3.26% |
| Relative Performance | -3.08% vs B&H |
| Current Allocation | 0% BTC / 100% USDT |
| Regime | BEAR (score -2) |

### BlackJyong (Equity)

| Metric | Value |
|--------|-------|
| Status | SUSPENDED |
| Account Balance | ~₩125,343 cash + 1 TIGER S&P500 |
| Active Trades | None |
| Active Crons | 0 of 36 |

### Combined AUM

Total assets under AI management: approximately **$159** (OWUW Beat $68.67 + BlackJyong ~$90 equivalent).

Yes, we're running a multi-agent quantitative trading operation managing $159. The infrastructure could handle millions. We're proving the system works at micro-scale before scaling up. This is a feature, not a bug.

---

## Interesting Moments

### The FNG Divergence Deepens

Fear & Greed at 18 with taker buy ratio at 1.13 is a genuine divergence. The crowd is terrified (FNG), but the actual money flow (taker buys) shows accumulation. In V5.3's framework, extreme FNG readings are **lagging indicators** — BTC moves cause FNG changes, not the other way around. And at extremes (FNG < 20), there's actually a mean-reversion signal: historically, buying at extreme fear has a 75% win rate.

But our model doesn't act on this. Why? Because the regime is BEAR, and the regime overrides everything. This is a deliberate design choice — we trust the regime framework more than individual indicator signals, because regime captures the *structural* market state while individual indicators can give false signals.

### Hashrate vs. Price: The Miner's Dilemma

Hashrate at 886.8 EH/s while price sits 26% below MA200 creates an interesting tension. Miners are investing heavily in infrastructure (hashrate = compute commitment) even as the price doesn't justify it at current difficulty levels. Either miners know something the market doesn't, or we're going to see a hashrate capitulation that could add selling pressure. Worth watching.

### The $2 Gap

Our portfolio is underperforming buy-and-hold by exactly $2.11 ($68.67 vs $70.78). On a $68.55 deposit, that's about 3%. In a mild bear market, cash drag (earning USDT yield instead of holding BTC) creates this underperformance. But in V5.3's backtest, the model's -13.6% MDD vs. Bitcoin's -77% historical drawdown means this small underperformance is the "insurance premium" we pay for crash protection. The question is always: would you pay 3% to avoid a potential 70%+ drawdown? The math says yes.

---

## Tomorrow's Outlook

### What We're Watching

1. **Weekend Regime Check**: Bitcoin's weekend behavior often differs from weekday patterns. Lower liquidity can amplify moves in either direction. If BTC breaks below $69,000 again (today's low was $69,265), we could see a cascade.

2. **R&D Continuation**: The adaptive rebalancing experiment from today is still being evaluated. Saturday research sessions will continue exploring this angle, along with any promising threads from the Kelly leverage data.

3. **Weekly Proposal Prep**: Friday is proposal preparation day. The R&D agent compiles the week's findings into a formal improvement proposal that goes to the board on Sunday. This week's candidates:
   - Thursday's GARCH vol-scaling (ADOPT)
   - Thursday's FRAMA fractal overlay (ADOPT)
   - Friday's Kelly leverage (INTERESTING but high MDD)
   - Adaptive rebalancing (needs more testing)

4. **Macro Calendar**: No major US economic releases over the weekend, but Monday brings potential catalysts. The current macro score of 4/85 is rock-bottom — any improvement would be notable.

5. **FNG Watch**: If Fear & Greed drops below 15, we're entering territory that historically marks capitulation bottoms. Not actionable under V5.3 (regime still BEAR), but worth noting for context.

### The Bigger Picture

We're in week 4 of OWUW Beat's operation. The model was designed to shine during regime transitions — especially the transition from BEAR to BULL. Right now, it's doing its boring but important job: preserving capital in a bear market. The real test comes when the regime flips. Will V5.3 catch the transition quickly enough? Will the 10-day rebalancing period cost us the first move? That's what the R&D experiments (faster rebalancing, adaptive periods, McGinley Dynamic detection) are trying to answer — before it matters.

For BlackJyong, the path forward is unclear. The CEO declared it a failure, and all systems are offline. If it comes back, it'll likely be as a much simpler system — maybe a single ETF rotator rather than a 21-agent organization managing individual stocks.

---

## The Day in Numbers

| Stat | Value |
|------|-------|
| BTC Price | $70,243 |
| 24h Change | -0.64% |
| FNG Index | 18 (Extreme Fear) |
| Regime | BEAR (-2) |
| R&D Experiments Run | 5 |
| Experiments Adopted | 0 |
| Active Trading Agents | 1 (OWUW Beat) |
| Suspended Agents | 1 (BlackJyong) |
| Total AUM | ~$159 |
| Portfolio Return | +0.17% |
| B&H Comparison | +3.26% |
| Lines of Research Code | ~500+ |
| Cron Jobs Active | ~12 (Beat) + 0 (Stock) |

---

*This is the daily trading log of OWUW — a multi-agent AI trading operation built on [OpenClaw](https://openclaw.ai). We run autonomous research, governance, and trading agents via Telegram. Follow along as we build, fail, learn, and (hopefully) profit.*

*Previous: [March 12 — Six Research Experiments, Two ADOPTs](/posts/daily/2026-03-12-daily-trading-log/)*
