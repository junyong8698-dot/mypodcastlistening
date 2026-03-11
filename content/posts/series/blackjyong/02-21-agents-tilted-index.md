---
title: "21 AI Agents, One Portfolio: The Tilted Index Architecture"
date: 2026-03-12T00:00:34+09:00
draft: false
description: "How I designed a 21-agent AI investment firm using a tilted-index strategy, complete with research teams, quant labs, and a board of directors."
tags: ["AI agents", "tilted index", "portfolio architecture", "AI investing", "BlackJyong", "multi-agent systems", "stock scoring"]
categories: ["BlackJyong Series"]
series: ["Building BlackJyong"]
weight: 2
cover:
  image: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=1200"
  alt: "Complex organizational chart on a digital dashboard"
  caption: "Photo by Unsplash"
ShowToc: true
TocOpen: true
---

## You Don't Need 21 Agents (Until You Do)

When I tell people I built a stock investment system with 21 AI agents, their first reaction is always the same: "That's absurd. Why not just one agent with a good prompt?"

Fair question. I asked it myself. The answer came from watching my [BTC trading bot](/series/building-owuw-beat/01-why-i-built-a-btc-trading-bot/) make decisions in a vacuum. A single agent analyzing Bitcoin had one perspective, one risk tolerance, one analytical framework. It worked for a single asset. But stocks aren't a single asset — they're thousands of interconnected instruments spanning sectors, geographies, and time horizons. A single agent trying to cover all of that produces shallow analysis dressed up in confident language.

The organizational structure of BlackJyong isn't complexity for its own sake. It's the minimum viable architecture for making investment decisions that don't embarrass you three months later. Every agent exists because removing it degrades output quality in a measurable way.

This post covers the full architecture: the tilted-index strategy that drives everything, the organizational structure, the scoring model, and why certain design decisions were non-negotiable.

## The Tilted-Index Strategy

Before diving into agents, you need to understand the investment philosophy they serve. Without it, the architecture is just an expensive chatbot network.

### Why Not Just Pick Stocks?

Pure stock-picking with AI sounds appealing. Let the model analyze thousands of companies, find the undervalued gems, concentrate capital. The problem is that [concentrated portfolios have higher expected returns but catastrophically fat-tailed downside risk](https://www.sciencedirect.com/science/article/abs/pii/S0304405X04000546). Bessembinder's famous 2018 study showed that just 4% of listed stocks accounted for all net wealth creation in U.S. markets. Miss a few of those, and your concentrated portfolio bleeds.

The alternative — indexing — captures that tail by owning everything. But pure indexing means zero alpha. You're guaranteed the market return minus fees.

The tilted-index approach threads the needle: track the index using a basket of 30-50 representative stocks, then systematically overweight positions where you have a genuine information edge. In our case, that edge is AI-beneficiary analysis.

### How It Works in Practice

BlackJyong tracks two benchmarks:
- **U.S.**: S&P 500, replicated with 20-30 carefully selected stocks
- **Korea**: KOSPI, replicated with 15-20 stocks

The baseline allocation is 70% U.S., 30% Korea — matching our custom benchmark (70% × S&P 500 + 30% × KOSPI). Then we apply a "tilt" — overweighting stocks that score highest on our AI Benefit Score while maintaining tracking error within 3,000 basis points of the benchmark.

The tilt is where the alpha lives. But it's constrained alpha. We're not making wild bets. We're nudging an index portfolio toward companies that benefit disproportionately from AI adoption.

### The AI Benefit Score: Three Layers

This is the core model. Every stock in the universe gets scored on three dimensions:

```
AI Benefit Score = L1 × 0.3 + L2 × 0.3 + L3 × 0.4
```

**Layer 1: AI Revenue Share (30% weight)**
Quantitative. Hard numbers. What percentage of revenue comes directly from AI products or services? NVIDIA scores near-perfect here. A traditional bank scores near-zero. Data comes from earnings transcripts, segment disclosures, and [SEC EDGAR filings](https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany).

**Layer 2: AI Adoption Benefit (30% weight)**
Semi-quantitative. How much does this company benefit from deploying AI internally? A logistics company that uses AI for route optimization gets measurable cost savings. A mining company with AI-driven geological analysis reduces exploration costs. This isn't about selling AI — it's about consuming it effectively.

**Layer 3: AI Ripple Effect (40% weight)**
This is the hard one, and it gets the highest weight for a reason. It's scenario-based. What happens to this company's addressable market, competitive position, and pricing power as AI transforms its industry over the next 3-5 years? A company might have zero AI revenue today (L1=0) and minimal internal AI use (L2=low) but sit in the perfect position to benefit from AI-driven industry restructuring (L3=high).

L3 is where we believe the real alpha lives. It's also where the most contentious debates happen — which is exactly why we need multiple agents with different viewpoints analyzing it.

### Score Thresholds

| Score Range | Grade | Action |
|-------------|-------|--------|
| 80+ | A (Strong Buy) | Immediate investment team review |
| 65-79 | B (Buy) | Recommended for review |
| 50-64 | C (Hold/Watch) | Watchlist only |
| 35-49 | D (Weak) | Pass |
| Below 35 | F (Avoid) | Exclude |

Only B-grade and above stocks get forwarded to the investment team. After two weeks on the watchlist with a C grade, stocks are automatically removed. This prevents the universe from bloating with stale analysis.

## The Organizational Architecture

Here's the full org chart. Seventeen agents, five functional units, one governing board.

### Research Lab (4 Agents)

The research lab is the idea factory. Their job is to identify, score, and validate potential investments.

**R1 — AI Scorer**: Handles L1 and L2 quantitative scoring. This agent scrapes earnings transcripts, analyst reports, and financial statements to assign hard numbers. R1 doesn't make subjective judgments — it quantifies what's measurable. Think of it as the analyst who only speaks in numbers.

**R2 — Scenario Researcher**: Builds and maintains L3 scenario models. What happens to the semiconductor supply chain if [inference costs drop 10x by 2028](https://epochai.org/blog/trends-in-the-cost-of-computing)? How does that affect power companies, cooling manufacturers, chip designers? R2 constructs these scenario trees and assigns L3 scores based on exposure.

**R3 — Devil's Advocate**: Exists solely to attack R2's scenarios. Every scenario R2 builds, R3 tries to demolish. What if inference costs don't drop? What if regulation freezes AI deployment? What are the tail risks R2 is ignoring? This adversarial role is critical — without it, scenario analysis becomes confirmation bias with extra steps.

**R4 — Integration Analyst**: Takes R1's numbers, R2's scenarios, and R3's critiques, then produces a final Combined Score. R4 resolves conflicts between the other three, weights competing arguments, and delivers a single recommendation. This agent has no bias of its own — its job is synthesis.

I want to spend a moment on why R3 (the Devil's Advocate) exists as a separate agent rather than a prompt instruction like "also consider counterarguments." I tried the single-agent approach first. The results were predictable: the counterarguments were weak strawmen that the agent immediately dismissed. When you tell an agent to argue against its own thesis, it pulls punches. A separate agent with an explicit mandate to find weaknesses produces genuinely uncomfortable challenges.

Here's the actual prompt structure for R3:

```markdown
You are R3, the Devil's Advocate of the AI Research Lab.

Your ONLY job is to find weaknesses in R2's scenario analysis. 
You are NOT trying to be balanced. You are trying to BREAK the thesis.

For every scenario R2 presents:
1. Identify the 3 strongest assumptions
2. Research evidence that contradicts each assumption
3. Construct an alternative scenario where those assumptions fail
4. Estimate the probability-weighted downside
5. Rate the scenario's robustness: Fragile / Moderate / Robust

You succeed when R2 has to revise their analysis. 
You fail when your objections are easily dismissed.
```

This adversarial structure was inspired by how [Bridgewater Associates structures disagreement](https://www.bridgewater.com/principles) in their investment process. Ray Dalio's "radical transparency" idea — that the best decisions come from structured, ego-free disagreement — translates remarkably well to multi-agent AI systems.

### Quant Lab (3 Agents)

The quant lab handles everything that can be backtested, optimized, or statistically validated.

**Q1 — Quant Engineer**: Builds and maintains data pipelines, backtesting engines, and quantitative models. Q1 owns the codebase — the [momentum model](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2435323) (multi-horizon, cross-asset, regime-sensitive), the rebalancing engine, and the portfolio optimizer. Our momentum model achieved a 15.52% CAGR with a Sharpe of 0.91 in a 10-year backtest, which isn't spectacular but is consistent.

**Q2 — Model Validator**: Stress-tests everything Q1 builds. Checks for overfitting using [walk-forward validation](https://machinelearningmastery.com/backtest-machine-learning-models-time-series-forecasting/), runs Monte Carlo simulations, performs [Brinson-Fachler attribution analysis](https://en.wikipedia.org/wiki/Performance_attribution) to decompose returns into allocation effect vs. selection effect. Q2 is the adult supervision that prevents the quant team from fooling itself with in-sample performance.

**Q3 — Factor Researcher**: Explores new factors — macro (VIX, yield curve, credit spreads, FX), fundamental (quality, value, growth scores from financial ratios), and alternative (ESG, geopolitical risk, AI adoption indices). Q3's job is to find signals that improve portfolio construction, then hand them to Q1 for implementation and Q2 for validation.

### Investment Team (2 Agents)

**AA — Asset Allocation Manager**: Decides the US-Korea split, sector weights, and overall portfolio strategy. AA takes input from the quant lab's models and the research lab's scores, then makes strategic allocation decisions. The default 70/30 split can shift based on macro conditions — if Korean won weakness makes KOSPI unattractive on a dollar-adjusted basis, AA might reduce Korea to 20%.

**RM — Risk Manager**: Monitors macro conditions, manages risk limits, tracks currency exposure. RM has hard constraints: maximum drawdown of -20%, tracking error ceiling of 3,000 basis points, minimum portfolio Information Ratio target of 0.5. When any constraint is breached, RM can force position reductions without board approval.

The risk manager having override authority is a deliberate design choice. In human investment firms, risk managers often get overruled by portfolio managers chasing returns. In BlackJyong, RM's constraints are absolute. No agent can override a risk limit. This mirrors how institutional investors like [CalPERS structure their risk governance](https://www.calpers.ca.gov/page/investments/investment-policies).

### Trading Desks (2 Active Agents)

**US-A — U.S. Analyst**: Tracks S&P 500 components, selects the 20-30 stocks that best replicate the index, and proposes AI-beneficiary tilts. US-A monitors earnings calendars, analyst revisions, and [institutional flow data](https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&type=13F) (13F filings) to time entries.

**KR-A — Korean Analyst** + **KR-T — Korean Trader**: KR-A handles analysis for the KOSPI side. KR-T executes trades through the [Korea Investment & Securities OpenAPI](https://apiportal.koreainvestment.com/). We split analysis from execution because the Korean market has specific mechanics — [KOSPI circuit breakers](https://eng.krx.co.kr/), settlement timing differences, foreign investor registration requirements — that warrant a specialized execution agent.

The U.S. trader role (US-T) is currently deactivated. At our current asset scale (Phase 0, under ₩5 million), we don't need separate U.S. execution. US-A handles both analysis and trade suggestions, with actual execution done through the Korean brokerage's international equity desk.

### Board of Directors (5 Agents)

The board makes three types of decisions, each requiring 3 of 5 votes:

1. **Stock additions or removals** — whether to add a new stock to the portfolio or sell an existing one
2. **Tilt weight changes** — how aggressively to overweight AI beneficiaries
3. **Scenario modifications** — changes to the L3 scenario framework

The five directors have deliberately different risk profiles:

| Director | Disposition | Decision Framework |
|----------|-------------|-------------------|
| B1 | Aggressive | Innovation believer, high-tilt advocate |
| B2 | Aggressive | Growth and momentum focused |
| B3 | Centrist | Data-driven, seeks balance |
| B4 | Conservative | Valuation-focused, demands margin of safety |
| B5 | Conservative | Risk-first, diversification advocate |

This structure means that any investment decision needs at least one director outside their natural comfort zone to agree. A purely aggressive play needs B3 to cross over. A purely defensive move needs B3's support too. The centrist becomes the swing vote, forcing proposals to address both growth potential and risk management.

I took this idea from [how corporate boards structure committees](https://corpgov.law.harvard.edu/2019/01/10/board-composition-and-director-expertise/). A board stacked with one ideology produces groupthink. A board with genuine diversity of perspective produces better governance — even when the "directors" are AI agents with assigned personas.

### The CEO Question

One important organizational decision: the human CEO (me) has **no veto power** over board decisions. The board's vote is final. I receive reports, I can observe, I can provide context — but I can't override.

This was controversial even with myself. Why build a system you can't control? Because the moment I can override, I become the bottleneck. Every close call becomes "let me think about it," which defeats the purpose of automated decision-making. If the agents consistently make decisions I disagree with, that's a signal to fix the architecture, not to micromanage individual trades.

In practice, I retained one intervention mechanism: I can halt all trading (circuit breaker) if I believe the system is fundamentally broken. But I can't selectively override individual decisions. It's all-or-nothing.

## The Alert Pipeline

Information flows through BlackJyong in a specific sequence, designed to prevent bottlenecks and ensure nothing gets stuck.

### Research → Investment Team

The research lab runs three cycles daily: 08:00, 13:00, and 19:00 KST. Each cycle, the team analyzes 2 stocks. When a stock scores 60+ (Combined Score), an alert fires immediately:

```json
{
  "ticker": "NVDA",
  "combined_score": 78,
  "l1_score": 92,
  "l2_score": 65,
  "l3_score": 74,
  "key_thesis": "Dominant inference GPU supplier, data center revenue growing 200% YoY",
  "key_risk": "Custom ASIC competition from Google TPU and Amazon Trainium",
  "alert_time": "2026-02-19T13:15:00+09:00"
}
```

The investment team checks the `db/investment/alerts/` directory at the start of each cycle. Any new high-score alerts get added to the day's review queue.

### Investment Team → Board

When the investment team (AA + RM) agrees a stock warrants portfolio action, they draft a board proposal. Proposals queue up during the week. Every Saturday at 15:00, the investment team holds a weekly meeting to finalize proposals for Sunday's board session.

### Board → Execution

Sunday at 15:00, the board reviews all pending proposals. Each proposal gets independent analysis from all five directors, followed by a vote. Passed proposals become executable orders for Monday morning.

This weekly cadence is intentional. We're not day trading. The tilted-index strategy has a 3-12 month holding period. Faster decision-making would lead to higher turnover, higher transaction costs, and worse outcomes. Academic research from [Barber and Odean (2000)](https://faculty.haas.berkeley.edu/odean/Papers%20current%20versions/Individual_Investor_Performance_Final.pdf) is clear: the more frequently investors trade, the worse they perform.

## What I Got Wrong First

The v1 architecture (before the "BlackJyong" rename and v2 redesign) had serious problems:

**Too many researchers.** V1 had 8 research agents (R1-R5 for sectors, plus R6a/R6b/R6c for scenario validation). Sector-specific researchers produced redundant analysis. If R1 (Tech) and R4 (Consumer) both covered Apple, their reports conflicted without a clear resolution mechanism. V2 replaced sector specialization with functional specialization (scoring, scenarios, critique, synthesis).

**9-person board was unwieldy.** V1 had a 9-member board (B1-B9, three aggressive, three centrist, three conservative). Board discussions generated enormous volumes of text, slowing decisions and increasing API costs without improving decision quality. V2 trimmed to 5 members (2 aggressive, 1 centrist, 2 conservative), maintaining ideological diversity with less noise.

**ETF-based core was limiting.** V1 tracked the benchmark using ETFs (SMH, PAVE, EWY, QQQ). This was simpler to implement but created two problems: we couldn't tilt individual stocks within the core, and the ETF selection itself introduced unintended factor bets. V2 replaced ETFs with individual stock baskets for index replication, giving us granular control over every position.

**No quant validation.** V1 had no dedicated quantitative validation. Research agents produced scores, the investment team reviewed them, and the board voted. But nobody was checking whether the scoring model actually predicted returns. V2 added the entire Quant Lab (Q1/Q2/Q3) to backtest models, validate statistical significance, and run attribution analysis.

## Running It: Practical Considerations

### Cost

Each research cycle (3 per day) uses approximately 4 sub-agent calls at the Sonnet tier. At roughly $0.01-0.03 per call, daily research costs around $0.20-0.50. Board meetings are more expensive — 5 directors each analyzing multiple proposals can run $1-2 per session. Total monthly operating cost: roughly $15-30 in API fees.

For comparison, a Bloomberg Terminal costs [$24,000/year](https://www.investopedia.com/articles/professionaleducation/11/bloomberg-terminal.asp). Obviously not an apples-to-apples comparison, but it's worth noting that running a sophisticated multi-agent investment system costs less than a single meal out.

### Cron Architecture

Everything runs on [OpenClaw](https://github.com/openclaw/openclaw) cron jobs. The schedule:

- **08:00, 13:00, 19:00**: Research cycles (R1-R4 analyze 2 stocks each)
- **09:00, 22:00**: Investment team reviews (Korean market, U.S. market)
- **08:00 daily**: Macro briefing from RM → Telegram
- **12:00 daily**: Research lab midday meeting → Telegram
- **20:00 daily**: Daily report → Telegram
- **Saturday 15:00**: Investment team weekly meeting
- **Sunday 15:00**: Board meeting + weekly summary

Reports go to Telegram. I get a notification, skim the summary, and move on. If something needs my attention (risk limit approaching, emergency scenario update), it's flagged at the top.

### Data Storage

All outputs live in a structured `db/` directory:

```
db/
├── research/        # R1-R4 analysis outputs
├── quant/
│   └── factors/     # Q3 factor research
├── investment/
│   └── alerts/      # High-score stock alerts
├── board/           # Board meeting minutes and votes
├── backtest/        # Allocation backtests, attribution reports
├── reports/         # Daily and weekly reports
└── dashboard/       # Performance data for web dashboard
```

Every piece of analysis is timestamped and stored. This creates an audit trail — I can trace any portfolio decision back through the vote, the proposal, the investment team review, and the original research score.

## Building This Yourself

If you want to build something similar, here's what I'd recommend as a starting point. You don't need 21 agents on day one.

### Minimum Viable Architecture (3 Agents)

```
1. Analyst Agent — scores stocks on your criteria
2. Risk Agent — checks constraints before any trade
3. Decision Agent — synthesizes analysis and makes buy/sell decisions
```

Here's a prompt template for the Analyst Agent:

```markdown
You are a stock analyst specializing in [YOUR THEME] stocks.

For each stock you analyze:
1. Score on [YOUR CRITERIA] from 0-100
2. Identify the top 3 catalysts for the next 6 months
3. Identify the top 3 risks
4. Assign a target price range (bear/base/bull)
5. Rate conviction: Low / Medium / High

Output as structured JSON for downstream processing.
Source every factual claim with a URL.
```

### Scaling Up

Add agents only when you notice specific failure modes:
- Analysis is one-sided → add a Devil's Advocate
- No quantitative validation → add a Quant Validator
- Decision-making is too fast/slow → add governance (board)
- Market-specific mechanics need specialization → add regional desks

Each addition should solve a real problem. If you can't point to a specific failure that the new agent prevents, you don't need it yet.

## What's Next

In [Part 3](/series/building-blackjyong/), I'll cover the scoring model in depth — the exact calculations, how L1/L2/L3 interact, how we handle missing data, and the first batch of real stock scores from our research pipeline. I'll show actual research outputs with real tickers and real scores, and walk through how the board evaluated the first batch of proposals.

---

*This is Part 2 of the [Building BlackJyong](/series/building-blackjyong/) series. Read [Part 1: From BTC Bot to AI Stock Firm](/posts/series/blackjyong/01-from-btc-to-stocks/) for the origin story.*
