---
title: "Daily Trading Log — March 12, 2026: Six Research Experiments, Two ADOPTs, and a Bear Market That Won't Quit"
date: 2026-03-12T13:05:00+09:00
draft: false
tags: ["daily-log", "btc", "research", "quant", "bear-market"]
categories: ["Trading Log"]
summary: "BTC bounces to $70.7K in extreme fear territory while our R&D agent cranks out six experiments — GARCH vol-scaling and FRAMA fractal overlays both earn ADOPT status. BlackJyong remains suspended. A full day inside our multi-agent trading operation."
cover:
  image: "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=1200"
  alt: "Financial trading charts and data visualization"
  caption: "Photo by Unsplash"
---

## The Morning Pulse

Thursday, March 12th. Another day in what's shaping up to be a prolonged crypto winter — or at least a deep chill. Bitcoin is sitting at **$70,739**, up 1.16% over the past 24 hours, which sounds nice until you zoom out and realize we're still 25% below the 200-day moving average at $94,747. The Fear & Greed Index? A grim **15 — Extreme Fear**. And it's been stuck there for over a month now.

The broader picture: RSI at 55.8 (technically neutral), 20-day volatility at 58.9%, and a 7-day gain of 2.85% that feels more like a dead cat bounce than a reversal. The funding rate is slightly negative at -0.007%, while the taker buy/sell ratio sits at 1.17 — shorts are getting squeezed a bit, but nobody's celebrating.

Our regime model's verdict: **BEAR**, score -2. Recommended allocation: **0%**. We're on the sidelines, and that's exactly where we should be.

---

## OWUW Beat: The BTC Agent's Day

### Regime Assessment

OWUW Beat's daily market scan ran this morning and confirmed what we already knew — we're firmly in bear territory. The key numbers:

| Metric | Value | Signal |
|--------|-------|--------|
| BTC Price | $70,739 | Below MA50 ($72,834) and MA200 ($94,747) |
| Fear & Greed | 15 | Extreme Fear (1+ month) |
| Regime Score | -2 | BEAR |
| Funding Rate | -0.007% | Slightly short-biased |
| Hashrate | 944.52 EH/s | All-time high range |
| BTC Dominance | 56.95% | Flight to BTC from alts |

The analyst view notes an interesting tension: taker buy dominance (1.17 ratio) coexists with persistent extreme fear and negative funding. This is the kind of contradictory signal that traps eager traders into premature longs. Our model sees through it — no allocation change.

### Trading Activity

**Zero trades executed today.** When the model says 0% allocation in a bear regime, we listen. This is one of the hardest lessons in systematic trading: doing nothing is a position. The model has kept us out since the regime flipped to bear, and that discipline has preserved capital while BTC has bled from its highs.

No Binance Earn moves either — with 0% BTC allocation, there's nothing to park in flexible savings. Cash sits ready for the eventual regime flip.

### The Interesting Bit: Hashrate Divergence

One thing worth watching — the hashrate is at 944.52 EH/s, essentially at all-time highs. Miners aren't capitulating despite BTC trading 25% below its 200-day MA. This could mean:

1. Mining operations are more efficient/capitalized than in previous cycles
2. Miners are betting on a recovery and holding through the pain
3. When miner capitulation eventually hits (if it does), the selling pressure could be intense

Our model doesn't trade on hashrate directly, but it's a macro indicator the team monitors for structural shift signals.

---

## BlackJyong: The Stock Agent — Still on Ice

BlackJyong, our Korean and US equity trading agent, remains **fully suspended** as of the CEO's direct order on March 10th. All 36 cron jobs are disabled. The account holds 1 share of TIGER S&P500 ETF and approximately ₩125,343 in cash.

The suspension came after a frank assessment that the agent's early performance didn't meet expectations. Rather than letting it burn through more capital on unproven strategies, the CEO made the call to halt everything and regroup.

The KIS API infrastructure remains intact — the trading scripts work, the account is connected, and we can resume manual trades on CEO direction. But for now, BlackJyong is in deep hibernation mode.

This is actually a good governance example. Not every agent experiment works. Knowing when to pull the plug — even temporarily — is as important as knowing when to deploy. We'll revisit BlackJyong's strategy when market conditions and our conviction level improve.

---

## R&D Research: Six Experiments, Two Breakthroughs

This is where the real action was today. Our R&D research agent ran **six full backtesting experiments** between 8 AM and 1 PM, each testing a different quantitative overlay on our V5.3 regime-switching baseline model. Let's break them all down.

### Experiment 1: GARCH(1,1) Dynamic Vol-Scaling (8:00 AM) — ✅ ADOPT

**Hypothesis:** GARCH-predicted (forward-looking) volatility should outperform realized-vol scaling by capturing volatility clustering. Based on Daniel & Moskowitz (2016).

**What we tested:** Five variants of GARCH-based volatility scaling applied to V5.3 regime allocations — universal scaling, regime-conditional targets, bull leverage, GARCH+EWMA blend. Multiple rebalancing periods (5d, 7d, 10d).

**Results:**

| Variant | Sharpe | Total Return | MDD |
|---------|--------|-------------|-----|
| V5.3 Baseline (10d) | 2.69 | 15,328% | -19.4% |
| GARCH Vol-Scale (10d) | 2.39 | 5,203% | -16.3% |
| GARCH Regime-Conditional (10d) | 2.32 | 6,884% | -19.5% |
| **GARCH Leverage Bull (10d)** | **2.71** | **21,144%** | **-18.8%** |
| GARCH+EWMA Blend (10d) | 2.17 | 4,610% | -20.0% |

The winner: **GARCH Leverage Bull (10d)** with a Sharpe of 2.71 versus the baseline's 2.69, and a return boost from 15,328% to 21,144% with slightly *less* drawdown. Out-of-sample Sharpe: 1.77.

**Key Insight:** GARCH captures forward-looking volatility clustering that realized vol misses. The regime-conditional targets prevent over-scaling in bear markets while allowing aggressive positioning in low-vol bull regimes. The "leverage bull" variant specifically amplifies exposure when GARCH predicts low future volatility during bull regimes — a sweet spot.

**Verdict: ADOPT.** This is going into the production model consideration pipeline.

### Experiment 2: Momentum Acceleration Overlay (9:00 AM) — PROMISING

**Hypothesis:** Using the rate of change (second derivative) of the composite regime score as a timing signal should improve entries and exits.

**What we tested:** EMA-smoothed regime score acceleration with 160+ parameter combinations. When momentum accelerates, boost allocation; when it decelerates, reduce preemptively.

**Results:** Best config improved Sharpe from 1.84 to 1.93 with MDD of just -11.1%. Out-of-sample Sharpe: 1.41.

**Key Insight:** Second-derivative timing catches momentum shifts earlier than the raw score. The improvement is modest but the reduced drawdown is appealing.

**Verdict: PROMISING.** Needs more work on adaptive thresholds, but the concept has legs.

### Experiment 3: Hurst Exponent Adaptive Allocation (10:00 AM) — PROMISING

**Hypothesis:** The Hurst exponent (R/S analysis) can detect trending vs. mean-reverting phases. Scale up in trending markets (H > 0.5), down in choppy ones.

**What we tested:** Hurst at 30/60/90-day windows with linear scaling, regime overrides, vol interaction, and multiple rebalancing periods.

**Results:** Marginal improvement — Sharpe from 1.14 to 1.18, but with wide confidence intervals [0.35, 2.27] and worse MDD (-37.5% vs -35.1%). Out-of-sample Sharpe: 0.59.

**Key Insight:** The Hurst exponent adds some signal but the wide CI and poor OOS performance suggest it's not robust enough on its own. May work better as a secondary filter.

**Verdict: PROMISING** (borderline). Worth combining with other fractal measures but won't stand alone.

### Experiment 4: Hilbert Transform Adaptive Regime Overlay (11:00 AM) — PROMISING

**Hypothesis:** Hilbert Transform provides a non-parametric, adaptive trend filter that could add conviction to regime signals.

**What we tested:** V5.3 + Hilbert at 5d, 7d, and 10d rebalancing periods.

**Results:**

| Variant | Sharpe | Total Return | MDD |
|---------|--------|-------------|-----|
| V5.3 Baseline | 2.09 | — | — |
| V5.3 + Hilbert 10d | 2.23 | 66,965% | -25.1% |
| V5.3 + Hilbert 7d | 2.19 | 57,805% | -30.5% |
| V5.3 + Hilbert 5d | 1.46 | 15,019% | -51.1% |

The 10d variant shows genuine improvement: Sharpe 2.23 vs 2.09 baseline, with bull regime returns of 223.5%. Out-of-sample Sharpe: 1.73.

**Key Insight:** Hilbert Transform is a non-parametric way to extract instantaneous frequency and amplitude from price data. It doesn't assume stationarity, making it theoretically more robust during regime transitions.

**Verdict: PROMISING.** Next step is combining with asymmetric leverage and Hurst for dual confirmation.

### Experiment 5: FRAMA Fractal Dimension Overlay (12:00 PM) — ✅ ADOPT

**Hypothesis:** Fractal dimension measures market choppiness vs. trending behavior. Low FD (trending) → boost allocation; high FD (choppy) → reduce to filter whipsaws.

**What we tested:** Fractal dimension via Ehlers' method at multiple lookbacks. Five strategy types: FD-scaling, regime override, FRAMA trend confirmation, multi-scale FD, and FD+Vol combined. Multiple rebalancing periods.

**Results:**

| Variant | Sharpe | Total Return | MDD |
|---------|--------|-------------|-----|
| V5.3 Baseline (10d) | 2.69 | 15,302% | -19.4% |
| FRAMA Trend Confirm (10d) | 2.77 | 11,710% | -16.2% |
| FRAMA FD-Scale (5d) | 2.92 | 30,644% | -26.0% |
| **FRAMA Trend Confirm (5d)** | **3.04** | **20,913%** | **-21.6%** |

The winner: **FRAMA Trend Confirm (5d)** with a stunning Sharpe of 3.04 — a 13% improvement over baseline. Bootstrap CI [1.73, 2.95], MDD 95th percentile -31.2%, out-of-sample Sharpe: **2.04**.

**Key Insight:** Fractal dimension captures market microstructure quality that traditional indicators completely miss. The FRAMA trend confirmation acts as a whipsaw filter — it only lets the regime model trade when the market structure actually supports directional movement. This is subtle but powerful.

**Verdict: ADOPT.** The highest Sharpe ratio we've seen in recent experiments. This needs to be combined with the GARCH vol-scaling overlay for a potentially powerful compound improvement.

### Experiment 6: Kalman Filter Regime Detection (1:00 PM) — PROMISING

**Hypothesis:** A Kalman filter constant-velocity model on log(price) provides faster regime detection than traditional MA crossovers.

**What we tested:** Kalman-extracted velocity replacing MA crossovers for regime scoring. Acceleration added for trend strength. Five configurations combined with vol-targeting.

**Results:** Best variant "Kalman+VolTarget (5d)" achieved Sharpe 2.06, MDD -28.3%, return 6,434%. CI [1.43, 2.68], OOS Sharpe: 1.53.

**Key Insight:** Kalman velocity is a statistically principled alternative to MA crossovers. It naturally handles noise and adapts to changing dynamics. However, the improvement over V5.3's existing regime detection wasn't dramatic enough for immediate adoption.

**Verdict: PROMISING.** The hybrid potential — Kalman velocity + FRAMA confirmation — could be interesting.

---

## Research Summary Scorecard

| # | Experiment | Sharpe | vs Baseline | Verdict |
|---|-----------|--------|-------------|---------|
| 1 | GARCH Leverage Bull | 2.71 | +0.02 | ✅ ADOPT |
| 2 | Momentum Acceleration | 1.93 | +0.09 | PROMISING |
| 3 | Hurst Exponent | 1.18 | +0.04 | PROMISING |
| 4 | Hilbert Transform | 2.23 | +0.14 | PROMISING |
| 5 | FRAMA Trend Confirm | 3.04 | +0.35 | ✅ ADOPT |
| 6 | Kalman Filter | 2.06 | — | PROMISING |

Two ADOPTs in a single day is a strong result. The FRAMA overlay in particular — Sharpe 3.04 with an OOS of 2.04 — is the kind of finding that could meaningfully improve our production model.

---

## Macro Briefing Summary

The macro environment remains challenging for risk assets:

- **BTC below both major moving averages** — MA50 ($72,834) and MA200 ($94,747) — confirming structural downtrend
- **Extreme Fear persists** — FNG at 15 for 30+ consecutive days, indicating deep psychological damage to retail sentiment
- **Macro score: 4 out of 85** — overwhelmingly negative macro factors
- **Funding rate negative** — the derivatives market is net short, though this can paradoxically set up short squeezes
- **BTC dominance at 56.95%** — capital is rotating from altcoins to BTC as a relative safe haven within crypto, a classic risk-off signal

The one bright spot: hashrate at all-time highs suggests the mining infrastructure remains committed. This is the kind of fundamental divergence that historically precedes major bottoms — but timing that bottom is a fool's errand without a regime flip signal.

---

## Agent Collaboration

Today's workflow shows how our multi-agent system operates even in "quiet" market conditions:

1. **OWUW Beat's market scanner** runs at dawn, pulling BTC price data, derivatives metrics, on-chain data, and macro indicators into a structured daily market report
2. **The R&D research agent** operates on a scheduled pipeline — six experiments today, each building on prior findings (FRAMA builds on yesterday's fractal research, GARCH extends volatility work)
3. **Results feed forward** — today's two ADOPTs (GARCH + FRAMA) will be combined in future experiments, following the research agent's own "next steps" recommendations
4. **The regime model** provides the decision layer — regardless of how exciting the research is, trading decisions follow the current bear regime signal

BlackJyong's suspension means no equity-side collaboration today. When it's reactivated, the cross-asset signals (BTC regime informing equity positioning) will resume.

---

## Performance Snapshot

### OWUW Beat (BTC)
- **Current position:** 0% BTC (fully cash/stablecoin)
- **Regime:** BEAR (score -2)
- **Today's P&L:** $0 (no position)
- **Strategy:** Capital preservation mode

### BlackJyong (Stocks)
- **Status:** Suspended (CEO order, March 10)
- **Holdings:** 1× TIGER S&P500 ETF + ₩125,343 cash
- **Activity:** None

The "boring" days in bear markets are the ones that matter most. Every day we don't lose money in a -25% drawdown environment is a day we outperform anyone who stayed long.

---

## Interesting Moments

### The FRAMA Sharpe of 3.04

This is genuinely exciting from a research perspective. A Sharpe ratio above 3.0 with an out-of-sample confirmation of 2.04 is rare. The fractal dimension approach is theoretically elegant — it measures *how the market is moving*, not just where it's moving. Choppy, fractal markets get filtered out; smooth trending moves get amplified. It's the kind of signal that feels almost too good, which is why the bootstrap confidence intervals and OOS testing are crucial validation.

### Six Experiments in Five Hours

The R&D agent's throughput is remarkable. Each experiment involves:
- Downloading and processing market data
- Implementing the mathematical model
- Running backtests across multiple parameter sets
- Computing bootstrap confidence intervals
- Generating regime-specific performance breakdowns
- Writing structured conclusions and next steps

Six of these in a morning — with rigor that includes OOS testing and sensitivity analysis — would take a human quant team days.

### The Persistent Extreme Fear

Thirty-plus days of FNG below 20 is historically unusual. The last time we saw this duration of extreme fear was [the model tracks this], and it preceded a significant rally. But "historically unusual" isn't a trading signal — our model needs an actual regime flip, not just a gut feeling that fear is overdone.

---

## Tomorrow's Outlook

### What the Agents Are Watching

1. **Regime score evolution** — We're at -2. A move to -1 would signal the beginning of a regime transition. The 50-day MA ($72,834) is only 3% above current price — a break above could shift the technical score.

2. **FRAMA + GARCH combination experiment** — Tomorrow's R&D pipeline will likely test the combination of today's two ADOPT findings. If FRAMA's whipsaw filtering combines well with GARCH's volatility scaling, we could see a compound Sharpe improvement.

3. **Funding rate dynamics** — Negative funding with rising price creates short squeeze conditions. If BTC pushes above $71.2K (today's high), forced liquidations could accelerate a move.

4. **Friday positioning** — Historically, crypto sees increased volatility heading into weekends as derivatives traders adjust positions. The options expiry calendar may create additional movement.

5. **Macro data** — Any US economic data releases tomorrow could shift the macro component of our regime score. With only 4/85 positive macro factors, there's more room for improvement than deterioration.

### The Bigger Picture

We're in the "boring but important" phase of systematic trading. The model says stay out, so we stay out. The research pipeline keeps improving the model for when the next bull regime arrives. The discipline to follow the system — even when BTC has a +1.16% green day and you want to buy the dip — is what separates systematic from discretionary.

When the regime flips, we'll be ready with a better model than we had yesterday. That's the daily compounding advantage of a tireless AI research team.

---

*This is Day 67 of continuous OWUW operations. The agents never sleep. The market never stops. And somewhere in the fractal dimension of Bitcoin's price action, our FRAMA overlay just found something interesting.*
