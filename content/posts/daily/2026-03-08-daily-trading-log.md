---
title: "Daily Trading Log — March 8, 2026: Extreme Fear, Zero Allocation, and Building the Machine"
date: 2026-03-08T13:00:00+09:00
draft: false
tags: ["trading", "bitcoin", "crypto", "daily-log", "owuw", "blackjyong"]
categories: ["Daily Trading Log"]
summary: "BTC hovers at $67,427 under a persistent BEAR regime. FNG stuck at 12 — extreme fear for 30+ consecutive days. We sit at 0% allocation, fully in USDT, while shipping major infrastructure: a 2-Tier research system targeting 703 stocks, an automated board voting pipeline, and recovering 104 lost R&D experiments."
cover:
  image: "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=1200"
  alt: "Trading charts and data"
  caption: "Photo by Unsplash"
---

## The Big Picture

Saturday, March 8th, 2026. Another day where the market gives us nothing to trade — and everything to build.

Bitcoin sits at **$67,427**, locked inside a tight $67,943–$68,324 range that's been compressing for days. The regime remains unambiguously **BEAR**. Our composite regime score is **-2**, with four of six macro factors flashing red. The Fear & Greed Index reads **12** — deep in "Extreme Fear" territory — and it has been below 25 for over **30 consecutive days** now. That's not a dip. That's a mood.

For context: the 50-day moving average is $75,287 and the 200-day MA is $95,894. Bitcoin would need to rally 40%+ just to reclaim its 200-day. We are, by every quantitative measure our system tracks, in a sustained downtrend. And our system responds accordingly: **0% BTC allocation. 100% USDT. Cash is a position.**

Today's portfolio value ticked up +0.12%, entirely from stablecoin earn interest. Our cumulative outperformance versus Buy & Hold stands at **+1.59 percentage points**. In a market that's been bleeding for months, "doing nothing" has been the best trade. The machine told us to sit. We sat. And we're ahead because of it.

But "doing nothing" on the trading side doesn't mean doing nothing overall. Today was one of the most productive infrastructure days we've had in weeks. Let me walk you through everything.

---

## Market Overview: The Anatomy of Persistent Fear

Let me paint the full picture of what we're looking at.

### The Numbers

| Metric | Value | Signal |
|--------|-------|--------|
| BTC Price | $67,427 | Below MA50 and MA200 |
| MA50 | $75,287 | Price -10.4% below |
| MA200 | $95,894 | Price -29.7% below |
| Fear & Greed Index | 12 | Extreme Fear |
| FNG Streak | 30+ days | Below 25 continuously |
| Regime Score | -2 | BEAR |
| Macro Score | +36 | Slightly positive (divergence) |

### Regime Factor Breakdown

Our regime model uses six binary factors. Here's where each stands:

1. **MA50 Cross**: -1 (Price below MA50)
2. **MA200 Cross**: -1 (Price below MA200)
3. **Copper/Gold Ratio**: -1 (Risk-off in commodities)
4. **DXY (Dollar Index)**: -1 (Strong dollar headwind)
5. **Net Liquidity**: +1 (One bright spot — liquidity is actually expanding)
6. **NFCI (Financial Conditions)**: +1 (Conditions are accommodative)

So we have a 2-vs-4 split. The liquidity and financial conditions factors are positive — which is interesting and worth watching. These tend to be leading indicators. When liquidity expands while price is still depressed, it often sets the stage for the next move. But "often" isn't "always," and our system doesn't try to predict. It reacts.

### The Fear Overhang

Thirty-plus days of Extreme Fear is psychologically significant. At some point, extreme fear becomes the baseline, and markets either capitulate hard or slowly grind higher as sellers exhaust themselves. We've seen both patterns historically. Our system doesn't try to time the sentiment turn — it waits for the regime factors to flip. Until they do, we stay in cash.

The interesting macro divergence (positive liquidity + positive financial conditions vs. bearish price action) tells me the plumbing is there for a recovery. But the price needs to confirm it. Until MA50 or MA200 get reclaimed, until Cu/Au flips, until DXY weakens — we wait.

---

## OWUW Beat: Fixing the Foundation

OWUW Beat is our crypto trading system — the autonomous agent that manages BTC/USDT allocation based on regime signals. Today was all about infrastructure hardening after a series of frustrating technical issues.

### The .env Deadlock Saga (Finally Resolved)

This one has been haunting us. The `.env` file — which stores configuration variables for our dashboard — has deadlocked **four times** now. On macOS with iCloud sync, file locks can get into unrecoverable states where the file exists but can't be read. When this happens, our dashboard crashes completely because it can't load its configuration.

Previous fixes were band-aids: delete the file, recreate it, restart the server. It kept coming back because the root cause was architectural.

**The root cause**: Our `app.py` was calling `load_env()` on every single API request — five different endpoints, each opening and parsing `.env` from disk. Under concurrent requests, this creates a race condition that iCloud's sync layer turns into a deadlock.

**The permanent fix**: We restructured to a **read-once pattern**:
- `.env` is loaded exactly once at server startup into `os.environ`
- `load_env()` is now a no-op (it exists for compatibility but does nothing)
- A hardcoded `_ENV_DEFAULTS` dictionary serves as a fallback if `.env` is deadlocked even at startup
- This means even if iCloud corrupts the file again, the dashboard keeps running

This is one of those fixes that seems obvious in retrospect. Of course you shouldn't re-read a config file on every request. But when you're building fast and iterating, these patterns sneak in. The important thing is we caught it, understood it, and fixed it permanently.

Backup saved at `.backups/app.py.20260307` because we've learned to never trust a single copy of anything in this environment.

### Recovering 104 Lost R&D Experiments

This was a satisfying one. Our R&D research dashboard was only showing 3 reports instead of the 11+ we knew existed. Investigation revealed the issue: some of our daily research JSON files are formatted as bare arrays `[...]` while others are wrapped in a dictionary `{...}`. The API code only handled the dictionary format.

The fix was a normalization layer that detects bare lists and wraps them: `{'date': ..., 'experiments': list}`. We also had to delete two files (`2026-02-15.json` and `2026-02-25.json`) that were irrecoverably deadlocked.

Result: **11 reports and 104 experiments** are now visible in the dashboard. That's months of research work recovered with a one-line format check. The R&D pipeline has been churning out experiments this whole time — we just couldn't see them.

### News API Migration to Brave Search

Our news feed was empty because the CryptoCompare API had no key configured. Rather than hunting for API keys, we pivoted to **Brave Search News API** (`/res/v1/news/search`). The integration was clean — same data structure, better results. We now get 10+ BTC news articles updating regularly.

This is a pattern I want to highlight: when something breaks, don't just fix it — ask if there's a better replacement. Brave Search is faster, more reliable, and doesn't require managing yet another API key.

### Snapshot Reconstruction

Our `snapshots.json` file — which tracks daily portfolio state for charting — had been corrupted down to a single entry. We reconstructed **19 daily snapshots** covering February 16 through March 6 using yfinance BTC price history. Since our allocation has been 0% BTC the entire period, the reconstruction was straightforward: portfolio = USDT balance + Earn interest accrual.

The Buy & Hold comparison chart now renders properly, showing the divergence between our "do nothing" strategy and simply holding BTC through the bear market. Spoiler: doing nothing is winning.

### Performance API Restoration

A backup restore from March 2nd had inadvertently reverted our performance API fix. The `/api/performance` endpoint was trying to read from `performance_log.json` instead of calling `performance_tracker.calculate_performance()` directly. Re-applied the patch. Dashboard performance tab is back to live calculation.

---

## BlackJyong: Building the Stock Research Machine

BlackJyong is our Korean stock market research and allocation system. While OWUW Beat handles crypto, BlackJyong covers the equity universe. Today was a landmark day for BlackJyong — we shipped two major systems.

### 2-Tier Research System Launch

This is the big one. BlackJyong uses five research agents (R1 through R5), each covering different sectors of the Korean stock market. The problem: with **703 stocks** in our target universe, our current coverage was pathetically low.

**Before today**: R1 covered 26/125 stocks, R2 covered 7/198, R3 covered 11/97, R4 covered 12/123, R5 covered 9/160. That's **65 out of 703 stocks — just 9.2% coverage.** The agents were doing deep-dive research on individual names, which produces great analysis but terrible breadth.

**The 2-Tier solution**:

- **Tier 1 (Quick Scan)**: A rapid assessment format. Each agent scans 15 stocks per session, producing a condensed research card with key metrics, a preliminary score, and a flag for whether a deep dive is warranted.
- **Tier 2 (Deep Dive)**: The existing full research format. Reserved for stocks that Tier 1 flags as interesting or that are already in our portfolio.

We built and shipped:
- `scripts/coverage_tracker.py` — Tracks which stocks each agent has covered, maps agents to sectors, identifies coverage gaps
- `agents/research_tier_system.md` — The rulebook: tier determination logic, Quick Scan card format, escalation criteria
- Updated all 5 agent prompts (R1–R5) with the 2-Tier system section and coverage tracker references
- Had to recreate `R4_consumer.md` from scratch because the original was iCloud-deadlocked (seeing a theme here?)
- Updated **10 cron jobs** (5 daytime + 5 nighttime sessions per agent) with tier system instructions and coverage tracker marking, timeout bumped to 1800 seconds

**Expected throughput**: From ~12 stocks/day to **75 stocks/day** (5 agents × 15 stocks per session). At that rate, we hit full universe coverage in roughly **10 business days**. That's going from 9% to 100% coverage in two weeks. The power of systematic process design.

### Automated Board Voting System

BlackJyong has a "board of directors" — three AI agents that vote on portfolio allocation decisions. Previously, this was a manual process: someone had to read the board opinions, tally votes, and feed the result into the allocation engine. Today we automated the entire pipeline.

**What we built**:
- Modified prompts for all three board member agents to output structured voting data
- Built a manager-level tally procedure that aggregates votes
- Connected the output to A3 (the allocation agent), T1 (the trading agent), and R1–R5 (the research agents)
- Created two new cron jobs:
  - `BJ_Board_Tally` — runs daily at 15:30 KST, collects and counts votes
  - `BJ_A3_PostBoard_Rebal` — runs daily at 16:00 KST, executes the board's allocation decision

**First end-to-end test scheduled**: Tomorrow (Sunday) at **15:00 KST**. The board will convene, votes will be tallied automatically, and the allocation decision will flow through to execution. This is our first fully automated governance cycle.

I want to pause and note how remarkable this is. We have AI agents debating portfolio allocation, voting on it democratically, and an automated system executing the consensus decision. The human (me) set the rules, designed the system, and now observes. This is what "autonomous trading" actually looks like — not a black box making trades, but a structured decision-making process that happens to run without manual intervention.

### Dashboard Fixes: Lazy Loading & Universe Tab

Two quality-of-life improvements for the BlackJyong dashboard:

**Lazy Loading for Reports**: The periodic reports tab was loading all 71 report files sequentially on tab entry. In our iCloud environment, that took up to **213 seconds** — over three and a half minutes to render a tab. We switched to lazy loading: file names are collected on tab entry, but report content is only fetched when you click on a specific report. Only the latest report auto-loads. Night and day difference.

**Universe Tab Stock Details**: Two bugs fixed in the stock detail view:
1. AI Impact scores (D1–D5) only had total scores in `latest.json`, missing breakdowns. Fixed by async-loading from individual research card files.
2. Execution 4-factor scores had field name mismatches (`revenue_growth` vs actual field names like `momentum`, `liquidity`, `quality`, `value`). Straightforward rename fix.

### Satellite Watchlist Rendering

The satellite watchlist (our speculative/high-conviction picks outside the core universe) had a rendering bug from format inconsistency — some files used `{ticker: data}` dict format, others used `{stocks: [...]}` array format. Added auto-detection for both formats, plus scenario number-to-name mapping for all 10 scenarios and dual field name support for `current_score`/`satellite_score`.

---

## R&D Research: What the Experiments Tell Us

With 104 experiments now recovered and visible, let's look at the latest R&D daily report (covering March 6th data):

### Session Summary
- **11 research sessions** completed
- **10 experiments** evaluated
- **1 ADOPT**: Adaptive Rebalancing
- **5 PROMISING**: FRAMA Dual, Cross-Asset SPX, Trailing Stop, CPPI Hybrid, Vol Term Structure
- **4 REJECTED**

### The Star: Adaptive Rebalancing (ADOPTED — Sharpe 2.63)

This is our newest adopted strategy component. Adaptive Rebalancing adjusts the speed and aggressiveness of portfolio rebalancing based on whether we're in a stable regime or transitioning between regimes.

- **Sharpe Ratio: 2.63** — That's exceptional for any strategy, let alone a rebalancing overlay
- **Key Insight**: During regime transitions (BEAR→BULL or BULL→BEAR), faster rebalancing captures the move. During stable regimes, slower rebalancing reduces transaction costs and whipsaw

This has already been integrated into our production decision framework. The next regime transition will be the real test.

### Most Promising: FRAMA Dual

FRAMA (Fractal Adaptive Moving Average) Dual uses two FRAMA indicators at different timeframes to generate signals. It's showing strong results in backtests, particularly in trending markets. Still in the "promising" stage — needs more out-of-sample testing before we'd adopt it.

### Important Caveat: Baseline Discrepancy

One critical finding from this R&D cycle: our local V5.3 baseline **underperforms production** (Sharpe 1.05 vs 2.43). This means all R&D results need to be interpreted relative to the local baseline, not the production system. An experiment showing Sharpe 2.63 locally might perform differently in production.

We're aware of this and tracking it. The gap is likely due to data differences and execution assumptions between the local backtesting environment and the production system. Closing this gap is on the roadmap but not urgent while we're in a no-trade regime.

### The Other Promising Strategies

- **Cross-Asset SPX**: Using S&P 500 signals as leading indicators for crypto. Promising because equity markets often price risk-off before crypto does.
- **Trailing Stop**: Dynamic stop-loss placement based on volatility. Useful for protecting gains during the next bull phase.
- **CPPI Hybrid**: Constant Proportion Portfolio Insurance — guarantees a floor value while allowing upside participation. Interesting for risk-averse configurations.
- **Vol Term Structure**: Using the shape of the volatility term structure (contango vs backwardation) as a regime signal. Novel approach that could add orthogonal information to our existing factors.

---

## Performance Review

Let's talk numbers.

### Portfolio Performance

| Metric | Value |
|--------|-------|
| Daily Return | +0.12% |
| Source | USDT Earn interest |
| BTC Allocation | 0% |
| USDT Balance | ~68.63 USDT (Earn) |
| Regime | BEAR |
| Action Taken | None (hold cash) |

### vs. Buy & Hold

| Metric | Our Strategy | Buy & Hold |
|--------|-------------|------------|
| Cumulative Return | Positive (interest) | Negative (BTC decline) |
| Outperformance | **+1.59 percentage points** | Benchmark |

A 1.59 percentage point outperformance might not sound like much, but consider: we achieved this with **zero risk**. Our maximum drawdown during this period is essentially zero (stablecoin earn has no downside), while Buy & Hold experienced the full BTC drawdown from higher levels.

Risk-adjusted, this is an infinite Sharpe ratio period for us. You can't lose money holding USDT (assuming no depeg), and you earn yield. The system's job isn't to make money in bear markets — it's to **not lose money** in bear markets. Mission accomplished.

### The Bigger Picture

Our system has been in cash since the BEAR regime triggered. During that time:
- BTC has declined from higher levels to $67,427
- We've earned steady USDT interest
- The gap between our portfolio and Buy & Hold has widened every single day

This is the quiet, boring, incredibly important part of systematic trading that nobody talks about. The sexy part is catching the bull run. The part that actually determines long-term performance is avoiding the bear market. Ed Seykota said it best: "Win or lose, everybody gets what they want out of the market." We want to survive bear markets with our capital intact. The system is delivering exactly that.

---

## Technical Debt & Known Issues

Transparency is important. Here's what's still broken or incomplete:

1. **Dashboard V2 Market Report page**: Still empty due to field name mismatches. Investigation needed.
2. **`generate_periodic_report.py`**: Still missing. Periodic reports rely on manual generation.
3. **Investment Mandate document**: Still at V5.2, needs V5.3 update to reflect current system parameters.
4. **R&D cron interval**: Unclear whether the 30min→1hr change was applied. Need to verify.
5. **iCloud deadlock risk**: The `.env` fix is permanent, but other files remain vulnerable. `model_profile.json` has deadlocked twice. No systemic fix yet for non-`.env` files.

The iCloud issue deserves special mention. We're running a trading system on infrastructure that includes iCloud-synced directories. This is... not ideal. File deadlocks, sync conflicts, and phantom file states are a recurring theme in these logs. Long-term, we need to either move critical files out of iCloud-synced paths or implement a robust file access layer with retry logic and fallbacks. For now, we're playing whack-a-mole with individual files as they deadlock.

---

## Tomorrow's Outlook

### Market

No strong directional signal. The macro divergence (positive liquidity/financial conditions vs. bearish price/trend) creates a "wait and see" setup. Key levels to watch:
- **Downside**: Sub-$67,000 would be a new local low and could trigger accelerated selling
- **Upside**: $70,000 is the first psychological resistance; MA50 at $75,287 is the real test
- **Regime change trigger**: We'd need at least 2 of the 4 negative factors to flip for the model to consider moving out of BEAR

My gut says we're closer to a bottom than a top, but "closer" could still mean weeks or months. The system doesn't trade on gut feelings, and neither do I. We wait.

### OWUW Beat

Maintenance mode. The dashboard is more stable than it's been in weeks after today's fixes. The main agenda items:
- Verify all dashboard endpoints remain stable
- Monitor the R&D pipeline (now visible with 104 experiments)
- Begin investigation into the V2 Market Report page field name issue
- Consider updating the Investment Mandate to V5.3

### BlackJyong

**Big day tomorrow.** The first end-to-end test of the automated board voting system at 15:00 KST. This is the moment of truth — will the three board agents produce parseable votes? Will the tally system aggregate correctly? Will the allocation decision flow through to A3 and T1?

The 2-Tier research system's first enhanced-throughput run is also coming. We'll see if the agents can actually process 15 Quick Scan stocks per session as designed. If the math works out, we should see a meaningful jump in coverage from 9.2% toward our 100% target.

### R&D

The Adaptive Rebalancing strategy (Sharpe 2.63) is now part of our production framework. The real question is when we'll get to test it — it's designed to shine during regime transitions, and we're in a stable BEAR with no transition in sight. When the turn comes (and it will), this strategy should help us capture it faster than our previous approach.

FRAMA Dual remains the most interesting promising strategy. If it continues to perform in extended backtesting, it could be our next adoption.

---

## Closing Thoughts

Days like today remind me why systematic trading is as much about engineering as it is about markets. We didn't place a single trade. Our allocation didn't change by a single percentage point. But we:

- Permanently fixed a recurring infrastructure failure
- Recovered months of lost research data
- Built a system that will 10x our stock research throughput
- Automated an entire governance and decision-making pipeline
- Shipped half a dozen dashboard improvements

All of this happens while the market does nothing and our portfolio quietly earns interest. The bear market is boring for traders and exciting for builders. We're building.

The gap between a mediocre trading system and a great one isn't the signal — it's everything around the signal. The data pipeline, the dashboard, the research coverage, the automated governance, the fault tolerance. Today we made the machine better. Tomorrow we test a new piece of it. The market will turn eventually, and when it does, we'll be ready with a system that's been hardened through months of quiet improvement.

Position: **100% USDT. 0% BTC. Earning yield. Waiting.**

See you tomorrow.

---

*This is a daily trading log from the OWUW autonomous trading system. All trades and decisions are made by AI agents following quantitative rules. The human role is system design, monitoring, and infrastructure maintenance. Not financial advice.*
