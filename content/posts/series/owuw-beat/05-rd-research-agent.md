---
title: "Building an Autonomous R&D Agent for BTC Strategy Research"
date: 2026-03-16T00:00:05+09:00
draft: false
description: "How I built an AI research agent that runs 22 experiments per day, autonomously exploring new trading strategies to beat the current production model."
tags: ["R&D agent", "autonomous research", "BTC trading", "AI agent", "quantitative trading", "OpenClaw", "strategy optimization"]
categories: ["OWUW Beat Series"]
series: ["Building OWUW Beat"]
weight: 5
cover:
  image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=1200"
  alt: "Scientist working in a laboratory with multiple screens"
  caption: "Photo by Unsplash"
ShowToc: true
TocOpen: true
---

## The Model Is Never Done

In the [previous post](/series/building-owuw-beat/04-data-collection-pipeline/), I walked through the data pipeline that feeds OWUW Beat's regime detection model. At that point, I had a working system: six macro factors, three regimes (bull/bear/neutral), a 10-day rebalancing cycle, and a production model (V5.3) delivering a backtest Sharpe of 2.43 with -13.6% max drawdown.

Most people would stop there. Ship it, monitor it, move on.

I didn't. Not because V5.3 was bad — it was genuinely the best model I'd built. But I'd spent enough time in quantitative research to know that every model has a shelf life. Markets change. Regime transitions get faster. Factor correlations shift. The edge you found six months ago might be gone tomorrow.

So instead of treating V5.3 as the final answer, I built something more interesting: an autonomous R&D agent that runs continuously during market hours, exploring new strategies, testing new factors, and trying to beat the production model. Every single day. Without me touching it.

This post covers how that R&D agent works, what it's discovered (and failed to discover), and why having an AI do systematic research turned out to be more valuable than I expected.

## Why Automate Research at All?

Here's the honest version of how quantitative research usually works for a solo operator.

You have an idea. Maybe you read a paper about volatility targeting, or you notice Bitcoin correlating with Japanese CPI data. You fire up a Jupyter notebook. You spend three hours writing a backtest. You get excited about the results. Then you realize you forgot to account for look-ahead bias, or your train/test split is wrong, or the result doesn't survive transaction costs. You fix those things. Another two hours. The result is marginal. You feel deflated. You close the notebook and don't come back for a week.

This cycle — enthusiasm, coding, disappointment, procrastination — is the default mode for solo quant researchers. I went through it dozens of times building V5.1 through V5.3. Each version took weeks of manual experimentation, and most of that time was wasted on ideas that didn't work.

The R&D agent exists to break this cycle. Its job is simple: run experiments continuously, log everything, and surface anything worth looking at. It removes the emotional friction of research entirely. The agent doesn't get discouraged when an idea fails. It doesn't procrastinate. It doesn't cherry-pick results that look good. It just runs the next experiment.

## The Architecture

The R&D agent is an [OpenClaw](https://github.com/nicepkg/openclaw) cron job that fires every 30 minutes between 08:00 and 18:00 KST, Monday through Friday. That's 22 experiment slots per day, 110 per week.

Each invocation gets a detailed task prompt that includes:

1. **The current production benchmark** — V5.3's exact metrics (Sharpe 2.43, MDD -13.6%, CAGR 76.3%, Calmar 5.60)
2. **A list of research directions** — everything from new data sources to leverage strategies to ML approaches
3. **Previous experiment results** — so it doesn't repeat work
4. **Six adoption criteria** that any new model must pass before it can go to the board for a vote

The agent runs in an isolated session, meaning it gets a fresh context each time but can read files from the workspace. It writes Python scripts, executes them, captures the results, and saves everything to a structured JSON file.

Here's a simplified version of the cron configuration:

```
Schedule: */30 8-18 * * 1-5  (every 30min, 8am-6pm, weekdays)
Session: isolated
Timeout: 1800 seconds (30 minutes per experiment)
```

The task prompt is stored in `research/research_agent_task.md` — a living document that gets updated every time the production model changes. When V5.2 was replaced by V5.3, every reference in the task file was updated to reflect the new benchmark. This prevents the agent from optimizing against an outdated target.

## What the Agent Actually Does Each Session

A typical R&D session follows this pattern:

1. **Read the task file** — understand the current benchmark, research directions, and constraints
2. **Pick a research direction** — the agent chooses based on what hasn't been explored recently
3. **Write a Python experiment** — a self-contained backtest script that tests a specific hypothesis
4. **Execute it** — run the script against 2017-2026 BTC data
5. **Analyze results** — compare to V5.3 on all six criteria
6. **Save results** — write to `research/daily_research/` as both a `.py` file and a `.json` summary

Over the first few weeks, the agent produced 62 experiment scripts. Some were simple parameter sweeps. Others were sophisticated multi-factor overlays. A few were genuinely creative approaches I wouldn't have tried myself.

Let me walk through some real examples.

## Experiment Category 1: Leverage — The Persistent Temptation

One of the first things the R&D agent explored was leverage. This makes intuitive sense: if your model has a positive expected return, leveraging it should amplify gains. The agent tested six variants of regime-conditional leverage:

- **Fixed BULL leverage**: 1.3x, 1.5x, and 2.0x during bull regimes only
- **Asymmetric leverage**: 1.5x in BULL, 0.5x in NEUTRAL, 0x in BEAR
- **Volatility-targeted dynamic leverage**: scale leverage inversely to 30-day realized volatility
- **Faster rebalancing with leverage**: daily rebalancing at 1.3x

The results were unambiguous. Here's what the 1.3x BULL variant produced:

| Metric | V5.3 (1x) | 1.3x BULL |
|--------|-----------|-----------|
| Total Return | +17,921% | +1,540% |
| Sharpe | 2.43 | 0.83 |
| MDD | -13.6% | -79.8% |
| Calmar | 5.60 | 0.45 |

Read that again. Adding just 30% leverage to the BULL regime *destroyed* the strategy. Total return dropped by an order of magnitude. Max drawdown went from -13.6% to -79.8%. The Sharpe ratio fell from 2.43 to 0.83.

The 2.0x variant was even worse: +168% total return versus +17,921% unlevered. Leverage in crypto doesn't just reduce risk-adjusted returns — it reduces *absolute* returns over long periods because volatility decay compounds ruthlessly.

This was a result I already knew from manual research (it's documented in my [earlier post on regime detection](/series/building-owuw-beat/03-regime-detection-first-agent/)). But the R&D agent proved it rigorously across six different leverage implementations. There was no clever way to make leverage work for a BTC regime-switching strategy with 10-day rebalancing. The math simply doesn't support it.

The agent flagged this as a dead end and moved on. No emotional attachment to the idea. No "but maybe if I tweak this one parameter." Just: leverage doesn't work, here are six ways I proved it, next.

## Experiment Category 2: Alternative Rebalancing Frequencies

V5.3 rebalances every 10 days. Why 10? Because it tested best across the full sample. But the R&D agent explored this more systematically, testing rebalancing intervals from 1 day to 30 days:

```python
# From exp_adaptive_rebal.py
rebal_intervals = [1, 3, 5, 7, 10, 14, 21, 30]
results = {}
for interval in rebal_intervals:
    metrics = run_backtest(regime_model='v53', rebal_days=interval)
    results[interval] = {
        'sharpe': metrics.sharpe,
        'mdd': metrics.max_drawdown,
        'total_return': metrics.total_return
    }
```

The findings were nuanced. Daily rebalancing had the worst Sharpe (0.71) due to transaction cost drag and whipsaw during regime transitions. Weekly (7-day) was decent (Sharpe 1.89) but missed the sweet spot. 10-day came out ahead (Sharpe 2.43), and 14-day was surprisingly close (Sharpe 2.31) with slightly better MDD.

More interesting was the agent's attempt at *adaptive* rebalancing — shortening the interval when volatility spikes and lengthening it during calm markets. In theory, this should capture regime transitions faster while avoiding unnecessary trades during stable periods. In practice, the improvement was marginal (Sharpe 2.47 versus 2.43) and failed the parameter sensitivity test: changing the volatility threshold by ±30% caused Sharpe to swing between 1.8 and 2.6. Too fragile to trust.

## Experiment Category 3: New Factors

This is where the R&D agent earned its keep. While I was busy with other things, it was systematically testing new macro and on-chain factors that might improve regime detection.

**ETF flow data** — The agent pulled Bitcoin ETF inflow/outflow data (IBIT, FBTC, ARKB) and tested whether net ETF flows predicted regime transitions. The hypothesis: institutional money flowing into spot Bitcoin ETFs should lead price. The result: ETF flows had mild predictive power for 5-day returns (r² = 0.08) but added nothing to regime classification beyond existing factors. ETF flows are too correlated with price momentum, which the MA50 slope already captures.

**Options market signals** — Put/call ratio, implied volatility skew (25-delta), and max pain levels. The put/call ratio showed promise as a contrarian indicator at extremes (>1.5 or <0.3), but the options market for Bitcoin only became liquid enough for reliable data after 2021. Five years of data isn't enough for the bootstrap confidence interval test.

**Stablecoin supply changes** — USDT and USDC market cap changes as a liquidity proxy. This was actually interesting: a rapid expansion in stablecoin supply preceded bull regime transitions by 2-3 weeks in four out of five historical instances. But the sample size (five regime transitions) was too small for statistical significance, and the data is only available from 2019 onward.

**Miner outflow** — The volume of BTC leaving known miner wallets. Classic on-chain metric, often cited by crypto analysts. The R&D agent found zero predictive power after controlling for price momentum. Miners sell when price is high; price being high is already captured by the regime model. Miner outflow is a lagging indicator dressed up as a leading one.

None of these factors cleared the adoption criteria for V5.4. But the stablecoin supply signal went into a "watch list" for future exploration once more data accumulates.

## Experiment Category 4: Machine Learning Approaches

I had already tried random forests and gradient boosting during the initial development phase and gotten nowhere — around 52% accuracy with ~300 weekly samples, barely better than a coin flip. But the R&D agent was instructed to try again with different approaches.

It tested:

- **LSTM networks** on daily price sequences (60-day lookback)
- **XGBoost with engineered features** (rolling statistics, cross-correlations, regime dummies)
- **Transformer-based models** (attention mechanism on macro factor time series)
- **Ensemble methods** combining the ML predictions with the existing regime model

The LSTM achieved 58% directional accuracy on out-of-sample data, which sounds better than 52% but doesn't translate to meaningful trading improvement when you account for the model's tendency to flip predictions rapidly (high turnover). XGBoost with the engineered features reached 61% accuracy but only on in-sample data; out-of-sample dropped to 53%.

The transformer approach was the most creative thing the agent tried. It treated the six macro factors as a multivariate time series and used self-attention to learn cross-factor relationships over time. The results were actually competitive in-sample (Sharpe 2.1) but the model had 12,000 parameters trained on 450 weekly observations. The ratio was absurd. Classic overfitting.

The honest conclusion: for BTC regime detection with limited historical data, traditional statistical methods (the factor-based scoring system in V5.3) outperform ML approaches. Machine learning needs more data than crypto markets can provide. This might change in five years when we have 15+ years of ETF-era Bitcoin data. For now, simpler is better.

## Experiment Category 5: Crash Defense Variations

V5.3's crash defense mechanism triggers when BTC drops 5% within 3 days, cutting allocation to 10% and then re-entering in two stages. The R&D agent explored alternatives:

**Trailing stop approach** — Instead of a fixed 5% threshold, use a trailing stop that tightens as unrealized gains increase. The backtest showed this *reduced* returns because it triggered exits during normal bull market pullbacks (5-8% drops that recovered within a week). V5.3's 3-day window filters these out; a trailing stop doesn't.

**ATR-based position sizing** — Scale position size inversely to the Average True Range. When ATR is high (volatile market), reduce exposure. When ATR is low (calm market), increase exposure. This is a well-known technique from [commodity trading advisors (CTAs)](https://www.man.com/maninstitute/systematic-trading-the-basics). The agent's backtest showed a Sharpe of 2.38 — close to V5.3 but not better, and the parameter sensitivity was marginal.

**Composite overlay** — Combine crash defense, macro urgency, and vol-targeting into a single risk score rather than applying them sequentially. This sounded smart but performed identically to V5.3 in backtests (the overlays rarely trigger simultaneously, so the order of application doesn't matter).

## The 6:00 PM Daily Report

At the end of each trading day, the R&D agent compiles everything it explored into a structured report sent to my Telegram. The format follows a principle I borrowed from Korean business communication: *두괄식* — conclusion first, then evidence, then methodology, then next steps.

A typical daily report looks like this:

```
📊 R&D Daily Summary — March 13, 2026

CONCLUSION: No V5.4 candidate found today.
Best result: Regime-Conditional Fractional Kelly (Sharpe 0.85)
— fails bootstrap CI and MDD criteria.

EXPERIMENTS (3 completed):
1. Kelly Leverage (6 variants) → all underperform V5.3
2. Volatility term structure signal → marginal (Sharpe 2.41)
3. Z-score regime replacement → worse (Sharpe 1.92)

NEXT DIRECTIONS:
- Cross-asset momentum (BTC vs ETH vs SOL regime correlation)
- Funding rate divergence as contrarian signal
- Yield curve slope as macro factor replacement for NFCI
```

Most days, the conclusion is "no candidate found." This sounds discouraging, but it's actually the most valuable output the agent produces. It's systematically eliminating the search space. Every failed experiment is one less thing to wonder about.

## The Weekly Governance Cycle

The R&D agent doesn't operate in isolation. It feeds into a weekly governance system that I described briefly in earlier posts but will cover in full detail in [Part 6](/series/building-owuw-beat/06-ai-board-of-directors/). The short version:

- **Friday 8:00 PM**: The agent compiles the week's best experiments into a formal proposal
- **Sunday 6:00 PM**: A 9-member AI board of directors votes on whether to adopt the proposal

The board has three progressive members, three conservative members, and three moderate members. A proposal needs a simple majority (5/9) to pass. Each board member evaluates the proposal against the six adoption criteria independently.

Since V5.3 was adopted on March 1st, no subsequent proposal has passed the board. This is actually correct behavior — the bar is high (all six criteria must be met), and incremental improvements are hard to find once you've already optimized the obvious things. The board's conservatism protects against overfit strategies that look good in backtests but would fail in production.

## The Six Adoption Criteria

Any strategy the R&D agent proposes must clear all six hurdles before it even reaches the board:

1. **Bootstrap Sharpe 95% CI lower bound > 0.5** — The strategy's risk-adjusted return must be statistically significant. A strategy with Sharpe 3.0 but a confidence interval of [-0.2, 6.2] doesn't pass.

2. **Monte Carlo MDD 95th percentile < -40%** — Under simulated worst-case scenarios, the max drawdown must stay above -40%. This eliminates strategies that look good on average but blow up in tail scenarios.

3. **Positive returns with and without 2017 data** — 2017 was an exceptional bull run. Any strategy that only works when 2017 is included is overfitting to that specific cycle.

4. **CAGR equal or greater than current model** — The new strategy must match or exceed V5.3's 76.3% CAGR. We don't trade Sharpe for lower returns.

5. **Out-of-sample validation** — 70% training / 30% test split. The test period Sharpe must exceed 0.3. This is deliberately lenient because crypto regime transitions are rare events; demanding high OOS Sharpe with limited data would reject everything.

6. **Parameter sensitivity** — Change any key parameter by ±30% and the Sharpe ratio must not drop more than 20%. This prevents strategies that only work at one specific set of parameters.

These criteria were developed iteratively. The first version had only three criteria and let through strategies that later proved fragile. Version 4 (the current set) was implemented during what I called "Phase 1 focused R&D" in late February 2026, where I froze the production model and spent two weeks building the validation framework.

## What the R&D Agent Can't Do

The agent has real limitations that I want to be honest about.

**It can't generate truly novel ideas.** The agent explores variations within the research directions I specify. It won't independently decide to look at, say, satellite data of Chinese mining facilities or social media sentiment from Weibo. Its creativity is bounded by the task prompt.

**It can't evaluate qualitative factors.** Some of the most important trading decisions are qualitative — a new regulation, a major exchange hack, a change in Federal Reserve communication style. The agent can backtest quantitative signals, but it can't incorporate soft information.

**It can't run live experiments.** Everything the agent does is backtesting on historical data. The gap between backtest and live performance is real and well-documented in [quantitative finance literature](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2460551). Slippage, execution timing, and data delays all degrade performance.

**It hallucinates data sources.** On two occasions, the agent wrote scripts that attempted to pull data from APIs that don't exist or endpoints that were deprecated. The scripts failed gracefully (try/except blocks), but I had to add explicit instructions about which data sources are actually available.

**It can't backtest options strategies.** Bitcoin options data with sufficient granularity for reliable backtesting simply doesn't exist before 2021, and even post-2021 data from Deribit requires a paid API. The agent can theorize about options strategies but can't validate them empirically.

## The Prompt That Drives Everything

The full R&D task prompt is about 150 lines long, but here's the core structure that makes it effective:

```markdown
# Research Agent Task

## Mission
Find strategies that beat the production model (V5.3).
V5.3 benchmark: Sharpe 2.43, MDD -13.6%, CAGR 76.3%, Calmar 5.60

## Constraints
- Long only + spot only (leverage/short proven failures)
- Minimum 7 years of backtest data (2017-2026)
- Must pass all 6 adoption criteria for board submission

## Research Directions
[Detailed list of 20+ specific ideas to explore, organized by category]

## Previous Failures (DO NOT REPEAT)
[List of approaches already tested and their results]

## Output Format
Save experiment script to research/daily_research/exp_{name}.py
Save results to research/daily_research/YYYY-MM-DD.json
```

The "Previous Failures" section is critical. Without it, the agent would repeatedly test the same ideas. I update this section weekly with anything definitively disproven.

If you're building your own research agent, here are the prompting principles that made the biggest difference:

1. **Give an explicit benchmark to beat.** Vague instructions like "find good strategies" produce vague results. Specific numbers create focus.

2. **List what not to do.** The negative space matters as much as the positive space. Every failed approach documented saves a future session from wasting time.

3. **Require structured output.** JSON results files and standardized Python scripts make it possible to compare experiments across days and weeks.

4. **Set a timeout.** 30 minutes per session forces the agent to scope experiments tightly. Without a timeout, sessions would expand to fill available time with diminishing returns.

## Cost and Efficiency

Running 22 AI sessions per day isn't free. Each session uses Claude as the underlying model through OpenClaw. At current pricing, the R&D agent costs roughly $3-5 per day in API calls, or about $100/month.

Is that worth it? Consider the alternative: me doing the same research manually. At 22 experiments per day, assuming each takes 30 minutes of focused work, that's 11 hours of research. Per day. No human can sustain that pace, and even if I could, my time is worth more than $5/hour.

The R&D agent isn't replacing a research team. It's replacing the boring, systematic part of research — the parameter sweeps, the factor testing, the validation checks — and freeing me to think about the interesting questions: what new data sources exist? What structural changes in the market might invalidate the model? What am I not measuring?

## What Happens When the Agent Finds Something Good

It hasn't happened yet for V5.4. But it happened for V5.3.

The crash defense mechanism that makes V5.3 special — the 5% / 3-day rule with two-stage re-entry — was discovered during automated R&D sessions in late February. The agent tested asymmetric exit/entry speeds (fast exit, slow re-entry) and found that combining this with a macro urgency overlay and bear volatility targeting produced a dramatic improvement over V5.2.

That finding went through the Friday proposal process, was evaluated by the 9-member AI board, and was approved 8-1 on March 1st, 2026. The lone dissenting vote came from a conservative board member who wanted three months of out-of-sample live data before deployment. (A reasonable objection that was overruled by the majority.)

The entire pipeline — from R&D discovery to board approval to production deployment — took 10 days. With a human-only process, that same cycle would have taken months. The speed advantage isn't just about running experiments faster; it's about the governance structure making decisions on a fixed schedule rather than waiting for someone to "feel ready."

## Building Your Own R&D Agent

If you want to replicate this for your own trading system (or any other domain where systematic experimentation matters), here's the minimal setup:

1. **Define your benchmark clearly.** Pick 3-5 metrics that fully characterize "good" for your domain.

2. **Write a task prompt** that includes the benchmark, research directions, and known failures. Store it as a file, not inline in the cron config, so it's easy to update.

3. **Set up a cron schedule** with appropriate frequency. For trading research, 30-minute intervals during market hours work well. For other domains, daily might be enough.

4. **Create a structured output format.** JSON works well. Include timestamp, hypothesis, methodology, results, and verdict.

5. **Build a review pipeline.** The R&D agent generates candidates; a separate process (human or AI board) evaluates them. Never let the research agent deploy its own findings directly to production.

6. **Update the task prompt weekly.** Add new failures, remove solved problems, adjust research directions based on what you're learning.

Here's a minimal OpenClaw cron setup:

```bash
# In your OpenClaw config
cron:
  - name: "R&D Agent"
    schedule: "*/30 8-18 * * 1-5"
    sessionTarget: isolated
    payload:
      kind: agentTurn
      message: "[contents of your task prompt]"
      timeoutSeconds: 1800
```

## The Bigger Picture

The R&D agent is the first piece of a larger system. In the next post, I'll cover [the AI board of directors](/series/building-owuw-beat/06-ai-board-of-directors/) — the governance layer that decides whether the R&D agent's discoveries get deployed to production. Together, the R&D agent and the board create something I hadn't expected: an autonomous research-and-deployment pipeline that improves itself without constant human supervision.

It's not perfect. The agent still can't match a skilled quant researcher for creative insight. But for systematic, exhaustive, emotionally-detached exploration of the strategy space? It's better than any human I know. Including me.

---

*This is Part 5 of the [Building OWUW Beat](/series/building-owuw-beat/) series. Next up: [Part 6 — The AI Board of Directors](/series/building-owuw-beat/06-ai-board-of-directors/), covering the 9-member governance system that votes on strategy changes every Sunday.*
