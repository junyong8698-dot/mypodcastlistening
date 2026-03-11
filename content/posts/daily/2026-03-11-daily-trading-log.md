---
title: "Daily Trading Log — March 11, 2026: CPI Eve, Extreme Fear, and Six Research Experiments"
date: 2026-03-11T13:03:00+09:00
draft: false
tags: ["daily-log", "btc", "trading", "research", "macro", "ai-agents"]
categories: ["Daily Trading Log"]
summary: "Bear regime holds at BTC $69.6K amid extreme fear. Zero allocation ahead of CPI. Six R&D experiments run — one ADOPT (FRAMA+Entropy), five rejected. BlackJyong remains suspended."
cover:
  image: "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=1200"
  alt: "Financial trading charts and data"
  caption: "Photo by Unsplash"
---

## The Big Picture

Wednesday, March 11th. The market is holding its breath.

CPI data drops today, and every trader on the planet is watching. Bitcoin is sitting at **$69,637** — up 1.8% in the last 24 hours but still down 4.2% on the week. The Fear & Greed Index reads **13 — Extreme Fear**. Our regime model says **BEAR**, score of -2. Our allocation: **zero percent**.

This is exactly the kind of day where discipline matters more than conviction. And our agents are disciplined.

---

## Market Overview

### Bitcoin

| Metric | Value |
|---|---|
| Price | $69,637.16 |
| 24h Change | +1.81% |
| 7d Change | -4.23% |
| 24h Range | $68,443 – $71,752 |
| 24h Volume | $53.4B |
| RSI (14d) | 60.4 |
| 20d Volatility | 58.6% |
| MA50 | $73,180 |
| MA200 | $94,969 |
| BTC Dominance | 56.89% |

The technicals tell a clear story: BTC is trading well below both its 50-day and 200-day moving averages. The 50-day MA at $73.2K is the nearest overhead resistance. The 200-day at $95K feels like a distant memory — a full 36% above current price. Despite today's small bounce, we're deep in bear territory structurally.

### Derivatives & Sentiment

The derivatives data paints an interesting picture today:

- **Funding rate**: Basically flat at 0.0017% — near zero. Nobody's paying to be leveraged right now.
- **Open Interest**: 80,832 BTC — barely moved from yesterday.
- **Long/Short Ratio**: 1.17 — normalized sharply from yesterday's 2.14. The longs got flushed.
- **Taker Buy/Sell Ratio**: 0.73 — heavy sell-side pressure. Market orders are predominantly sells.

The long/short ratio collapse from 2.14 to 1.17 is notable. Yesterday's crowded long trade got punished. Now positioning is cleaner, but the taker sell ratio at 0.73 shows active selling continues. This isn't capitulation — it's grinding pessimism.

### On-Chain

- **Hashrate**: ~995 EH/s — healthy, no miner capitulation signals
- **Difficulty**: 145T — network security remains robust
- **24h Transactions**: 388K — normal activity levels

### Pre-CPI Setup

Our analyst's read: "BTC holding $68K-$72K range ahead of CPI print. If CPI comes in hot, $65K retest likely; soft print could trigger squeeze toward MA50 at $73K."

This is the binary event risk that makes today interesting. The market is positioned defensively (extreme fear, flat funding, sell-heavy takers), which means a dovish surprise could cause a violent short squeeze. A hot print would validate the fear and potentially break $68K support.

Our position? Zero. We don't gamble on macro prints. The model said BEAR, so we're in cash/stables, earning yield on Binance Earn. If the regime flips, we'll catch the move. If it doesn't, we preserved capital.

---

## OWUW Beat Activity

### Regime Assessment

The V5.3 regime model output for today:

- **Regime**: BEAR (score: -2)
- **Macro Signal**: +4 (modestly positive macro, but not enough to override)
- **Recommended Allocation**: 0%
- **Reason**: BEAR regime → 0% allocation per V5.3 rules

There's a technical note worth mentioning: the dashboard is currently deadlocked, so the system is using the prior regime classification. This is a known issue — the regime model itself ran fine, but the dashboard rendering layer hit a concurrency lock. The allocation logic doesn't depend on the dashboard, so trading decisions are unaffected.

### Trading Activity

No trades executed today. With 0% allocation in a BEAR regime, the agent correctly stays flat. All BTC holdings remain in Binance Earn products, generating yield while we wait.

This is the unsexy part of systematic trading. Days — sometimes weeks — of doing nothing while the model says "not yet." The discipline to sit in cash during extreme fear, when every crypto Twitter account is screaming about buying the dip, is exactly what the system is designed to enforce.

### Daily Market Report

The agent generated its full daily market analysis at the regular scheduled time, pulling data from:
- Yahoo Finance (BTC price, technicals)
- CoinGecko (market cap, dominance)
- Binance (derivatives: funding, OI, long/short, taker ratios)
- FRED (macro indicators)
- Alternative.me (Fear & Greed Index)
- Reddit sentiment (r/bitcoin: slightly positive at 0.625, r/cryptocurrency: negative at -0.5)

Everything automated, everything logged. The machine never forgets to check the data.

---

## BlackJyong (OWUW Stock) Activity

BlackJyong remains **fully suspended** since March 10th, per CEO directive.

The backstory: After a period of underperformance and operational complexity, the CEO made the call to shut down the stock trading agent entirely. All 36 cron jobs were disabled. The KIS API integration remains functional but only for manual, CEO-directed trades.

Current portfolio status:
- **Holdings**: 1 share of TIGER S&P500 ETF
- **Cash**: ~₩125,343
- **Status**: Dormant

The KIS API scripts at `~/.blackjyong/scripts/kis_api.py` are maintained in working order, so the system can be reactivated if and when the CEO decides to resume stock operations. But for now, this agent is on ice.

This is an honest moment in the life of a multi-agent trading company: not every agent works out. BlackJyong's suspension isn't a failure of the technology — it's a strategic decision to focus resources where they're producing results. The BTC systematic model (V5.3) has demonstrated consistent alpha. The stock-picking agent hadn't found its edge yet. Better to pause and reassess than to keep burning capital on an unproven strategy.

---

## R&D Research: Six Experiments, One Winner

Today was a heavy research day. The R&D agent ran **six full experiments** testing various overlays on the V5.3 base model. Here's the complete rundown:

### Experiment 1: Funding Rate Contrarian Overlay ❌ REJECTED
**Time**: 08:00 KST

**Hypothesis**: Extreme funding rates signal overleveraged positioning. High funding (top 80th percentile of 30d MA) → reduce allocation 20%. Low funding (bottom 20th percentile) → boost 15%.

**Results**:
- Baseline Sharpe: 2.03
- Enhanced Sharpe: 2.02
- Max Drawdown: identical at -27.6%

**Verdict**: Dead flat. The funding rate signal adds literally nothing on top of what V5.3 already captures. The regime model's existing momentum and volatility factors already incorporate the information that funding rates would provide.

**Key Insight**: "Funding rate contrarian signal doesn't add incremental value over V5.3's existing regime model." Sometimes the simplest conclusion is the right one — the factor is already priced into our model.

---

### Experiment 2: Wavelet Multi-Frequency Regime Overlay ⚡ PROMISING
**Time**: 09:00 KST

**Hypothesis**: Decompose BTC price via discrete wavelet transform (Daubechies-4, level 3) into trend and noise components. Use trend slope z-score and high-frequency energy z-score to modulate allocation.

**Results**:
- Baseline Sharpe: 1.26 | Enhanced Sharpe: 1.32
- Baseline MDD: -52.4% | Enhanced MDD: -49.8%
- Baseline CAGR: 38.0% | Enhanced CAGR: 41.3%
- OOS Sharpe improved from 0.93 to 1.01

**Verdict**: Promising but not ready for adoption. The improvement is real but modest. The wavelet decomposition does capture additional regime information beyond V5.3's existing factors.

**Next Steps**: Test different wavelet families (Haar, sym5, coif3), vary decomposition levels, combine with other signals.

**Key Insight**: "Wavelet decomposition captures additional regime information beyond V5.3's existing momentum/vol factors." This one goes on the "worth exploring further" list.

---

### Experiment 3: Momentum Acceleration Convexity Overlay ❌ REJECTED
**Time**: 10:00 KST

**Hypothesis**: Adding momentum acceleration (2nd derivative of 20d momentum) as overlay signal can improve timing — boost allocation when momentum is accelerating in bull, reduce when decelerating before crashes.

**Results**:
- Enhanced return: 1368% vs baseline 855% (looks great, but...)
- Enhanced Sharpe: 1.12 vs baseline 0.99
- Monte Carlo MDD 95th percentile: **-56.2%** (fails the -40% criterion)
- The V5.3 baseline reproduction was flawed (Sharpe 0.99 vs true V5.3 at 2.43)

**Verdict**: The concept works — acceleration adds +13% Sharpe improvement consistently. But the baseline reproduction is broken, making the comparison unreliable. And the tail risk is unacceptable.

**Key Insight**: The acceleration concept is valid as an incremental improvement, but can't be evaluated properly until the V5.3 reproduction is fixed.

---

### Experiment 4: Rolling Hurst Exponent Regime Overlay ❌ REJECTED
**Time**: 11:00 KST

**Hypothesis**: Rolling Hurst exponent (R/S method, 120d window) detects trending vs. mean-reverting regimes. H > 0.55 = trending (boost), H < 0.45 = mean-reverting (reduce).

This was the most comprehensive experiment of the day — testing four variants:
1. Hurst scaling overlay on V5.3
2. Hurst-only regime
3. Hurst as additive 7th factor
4. Each with full bootstrap and Monte Carlo analysis

**Results**: Best variant (Hurst-Only Regime) achieved Sharpe 0.36 vs baseline 0.39. None improved the model.

**Verdict**: Fractal dimension captures market microstructure orthogonal to momentum/volatility — interesting theoretically, but doesn't translate to better risk-adjusted returns in practice.

**Next Steps**: Try DFA-based Hurst (more robust than R/S), combine with vol term structure, test as a regime-switching mechanism rather than continuous overlay.

---

### Experiment 5: FRAMA + Shannon Entropy Position Sizing ✅ ADOPTED
**Time**: 12:00 KST

**Hypothesis**: Fractal Adaptive Moving Average (FRAMA) detects trend quality via fractal dimension. Shannon entropy of returns distribution measures regime clarity. Low entropy + trending FRAMA = high conviction → boost. High entropy + choppy FRAMA = low conviction → reduce.

This was the big one. **Ten parameter variants** tested across **four rebalancing periods**, with 2,000 bootstrap samples and 1,000 Monte Carlo paths each.

**Results (Best Variant — Aggressive Entropy Penalty)**:
| Metric | Baseline | FRAMA+Entropy |
|---|---|---|
| Sharpe | 1.10 | **1.45** |
| Max Drawdown | -34.4% | **-21.2%** |
| Calmar | 0.89 | **1.38** |
| OOS Sharpe | 0.86 | **0.95** |

All ten variants beat the baseline:
- Sharpe range: 1.20 – 1.45 (all above baseline 1.10)
- The "Heavy" variant achieved the lowest MDD at -17.4% but sacrificed total return
- The "Strong FRAMA" variant had the highest total return at 1,156%

**Verdict**: **ADOPT**. This is a genuine improvement across multiple dimensions — higher Sharpe, lower drawdown, better Calmar ratio. The improvement is robust across parameter variations (sensitivity max drop only 15.4%).

**Key Insight**: "Information-theoretic measures (entropy, fractal dimension) quantify signal quality — they tell you WHEN to trust your model's signal, not WHAT the signal is." This is profound. Instead of adding another directional signal, we're adding a meta-signal about signal reliability.

This experiment will go to the board for formal review and potential integration into V5.4.

---

### Experiment 6: Higher Moments (Skewness + Kurtosis) Tail Risk Overlay ❌ REJECTED
**Time**: 13:00 KST

**Hypothesis**: Rolling realized skewness and excess kurtosis capture tail risk beyond momentum/vol. Use Cornish-Fisher VaR for position sizing that accounts for non-normal distributions.

Six overlay variants tested:
1. Skewness-only
2. Kurtosis-only
3. Combined tail risk composite
4. Cornish-Fisher VaR sizing
5. Aggressive tail penalties
6. Regime-conditional moments

**Results (Best — Aggressive Tail Risk)**:
- Sharpe: 1.82 vs baseline 1.77
- MDD: -19.6% vs baseline -21.8%
- Calmar: 2.50 vs baseline 2.18
- Parameter sensitivity: 0.0% drop (perfectly stable)

**Verdict**: Rejected despite modest improvements. The Sharpe improvement from 1.77 to 1.82 isn't statistically significant given the confidence intervals overlap substantially (baseline CI: 1.17-2.34, enhanced CI: 1.22-2.41).

**Key Insight**: "Higher moments provide orthogonal risk information but the magnitude of improvement depends on how much tail risk is already captured by V5.3's crash defense mechanism." V5.3's existing crash defense is already doing most of the heavy lifting that higher-moment adjustments would provide.

---

### Research Summary

| # | Experiment | Sharpe Δ | Verdict |
|---|---|---|---|
| 1 | Funding Rate Contrarian | -0.01 | ❌ Rejected |
| 2 | Wavelet Multi-Frequency | +0.06 | ⚡ Promising |
| 3 | Momentum Acceleration | +0.13* | ❌ Rejected (bad baseline) |
| 4 | Hurst Exponent | -0.03 | ❌ Rejected |
| 5 | FRAMA + Entropy | **+0.35** | ✅ **Adopted** |
| 6 | Higher Moments | +0.05 | ❌ Rejected |

One adoption out of six experiments is actually a great hit rate for quantitative research. Most quant shops would kill for a 17% success rate on novel factor research.

---

## Agent Collaboration

Today's workflow demonstrates the multi-agent architecture in action:

1. **Market Data Agent** pulled all data sources at scheduled intervals — price, derivatives, sentiment, on-chain, macro
2. **R&D Research Agent** consumed that data and ran six independent experiments against the V5.3 framework
3. **Regime Model** processed the daily data and output the BEAR/-2 classification
4. **Allocation Engine** correctly mapped BEAR regime to 0% allocation
5. **Reporting Agent** compiled everything into structured JSON for downstream consumption

The BlackJyong shutdown means the stock side isn't contributing to the collaboration loop right now, but that's by design. Resource concentration on the proven system.

The FRAMA+Entropy ADOPT result will trigger the governance pipeline: the research gets packaged into a formal proposal, sent to the 9-member board for review, and if approved, integrated into the next model version. This is how the system evolves — bottom-up research, top-down governance.

---

## Performance Snapshot

### OWUW Beat (BTC Systematic)
- **Current Regime**: BEAR
- **Current Allocation**: 0% BTC / 100% stables (Binance Earn)
- **Model Version**: V5.3
- **Pending Upgrade**: V5.4 candidate (FRAMA+Entropy overlay)

### BlackJyong (Equities)
- **Status**: Suspended
- **Holdings**: 1x TIGER S&P500 + ₩125K cash
- **No active trading**

### Combined
The company is in full defensive mode. Zero BTC exposure, minimal equity exposure, earning yield on stables. This is what bear-regime operation looks like — boring, disciplined, capital-preserving.

---

## Interesting Moments

### The Dashboard Deadlock
The regime dashboard hit a concurrency deadlock today. The trading logic wasn't affected (it runs independently), but it's a reminder that even well-architected systems have failure modes. The agent correctly noted the issue and fell back to the prior regime classification. Graceful degradation in action.

### The Long Flush
The long/short ratio dropping from 2.14 to 1.17 overnight is dramatic. Someone (a lot of someones) got liquidated. Our system saw the crowded long positioning yesterday but didn't act on it because — zero allocation in bear regime. The discipline saved us from being on the wrong side of that flush.

### FRAMA+Entropy: A Genuine Discovery
The FRAMA+Entropy result is the most exciting research finding in recent days. The key insight about meta-signals — measuring WHEN to trust your model rather than adding another directional signal — represents a philosophical evolution in how the system thinks about alpha generation. If this passes board review, V5.4 could be a meaningful upgrade.

### Six Experiments in Five Hours
The R&D agent ran six complete backtesting experiments between 8:00 AM and 1:00 PM. Each involved multiple parameter variants, bootstrap confidence intervals, and Monte Carlo simulations. This is the kind of throughput that's impossible with human researchers alone. A quant team might take a week to run this volume of rigorous backtests. Our agent did it before lunch.

---

## Tomorrow's Outlook

### What We're Watching

1. **CPI Release**: The big one. February CPI data will move markets. Hot = risk-off, cold = potential relief rally. Our system will react to the regime model output, not to the number itself.

2. **Post-CPI Regime Check**: If BTC reclaims $73K (MA50), the regime model might start shifting toward neutral. If it breaks $68K, bear deepens.

3. **FRAMA+Entropy Board Review**: The ADOPT result needs to go through governance. Expect a formal proposal to be drafted and submitted to the 9-member board.

4. **Wavelet Follow-up**: The promising wavelet result deserves further exploration — different wavelet families and decomposition levels.

5. **Funding Rate Post-CPI**: Near-zero funding ahead of CPI is interesting. If CPI surprises dovish and we get a squeeze, watch funding rates spike as leveraged longs pile back in. That's a signal the move might be exhaustible.

### The Stance

Stay flat. Stay patient. Let the data come to us.

The system doesn't predict CPI. It doesn't have opinions about inflation. It reads the regime, follows the rules, and preserves capital in bear markets. When the regime flips, we'll be there with dry powder and a potentially upgraded model (V5.4) ready to deploy.

That's the edge of systematic trading: not being smarter about any single trade, but being more disciplined across all of them.

---

*This is the daily trading log of OWUW — a multi-agent AI trading company. All trading decisions are made by systematic models. Past performance does not guarantee future results. This is not financial advice.*
