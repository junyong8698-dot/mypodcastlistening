---
title: "The AI Benefit Scoring Model: Rating Every Stock's AI Upside"
date: 2026-03-17T00:01:34+09:00
draft: false
description: "How I built a 3-layer scoring model that quantifies every stock's AI benefit — from revenue exposure to ecosystem positioning — with dynamic regime-based weighting."
tags: ["AI scoring model", "stock scoring", "AI investing", "BlackJyong", "quantitative analysis", "tilted index", "factor investing"]
categories: ["BlackJyong Series"]
series: ["Building BlackJyong"]
weight: 3
cover:
  image: "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=1200"
  alt: "Financial data analysis on multiple screens showing stock charts and scoring metrics"
  caption: "Photo by Unsplash"
ShowToc: true
TocOpen: true
---

## The Question That Breaks Most AI Investment Strategies

Here's the problem with "investing in AI": everyone agrees AI will transform the economy, but nobody agrees on which companies actually benefit.

NVIDIA is obvious. Microsoft, sure. But what about a Korean steel company that supplies materials for data center construction? What about an insurance company that deploys AI underwriting and cuts costs by 30%? What about a semiconductor equipment maker three tiers deep in the supply chain?

When I built [BlackJyong's 21-agent architecture](/posts/series/blackjyong/02-21-agents-tilted-index/), the organizational structure was just the container. The actual intelligence lives in the scoring model — a system that takes any publicly traded company and outputs a number representing how much it benefits from the AI revolution.

This post covers the AI Benefit Scoring Model v2.1: the three-layer architecture, the dynamic weighting system that adapts to market conditions, the data quality framework that keeps the model honest, and the prompts I use to make AI agents produce institutional-grade research.

## Why a Scoring Model Instead of Just Picking Winners

The tilted-index strategy I described in [Part 2](/posts/series/blackjyong/02-21-agents-tilted-index/) needs a continuous, comparable score for every stock in the universe. You can't tilt an index without knowing *how much* to tilt each position.

Most retail AI investment strategies boil down to conviction calls: "I think NVIDIA will keep growing" or "I'm bullish on AI infrastructure." That works until it doesn't, because conviction-based investing has three fatal flaws:

**It doesn't scale.** You can hold strong opinions about 10 stocks. You can't hold strong opinions about 200.

**It can't compare across sectors.** Is NVIDIA's AI exposure better than Samsung's? Is Palantir's AI revenue more durable than ServiceNow's? Without a common scoring framework, you're comparing vibes.

**It can't adapt.** Markets shift. A scoring model with dynamic weights adjusts automatically. Your gut feeling from six months ago doesn't update itself.

The scoring model solves all three. Every stock gets a number between 0 and 100. That number determines how much overweight or underweight it gets relative to the benchmark. The number updates as new data arrives. No vibes required.

## The Three-Layer Architecture

The model uses three layers that capture different dimensions of AI benefit. Each layer answers a different question:

- **Layer 1 (Revenue Exposure):** How much money does this company make from AI right now?
- **Layer 2 (Operational Integration):** How much does AI improve this company's operations and competitive position?
- **Layer 3 (Ecosystem Positioning):** Where does this company sit in the AI value chain, and how defensible is that position?

The final score combines all three:

```
Final_Score = AI_Benefit_Score (60%) + Quant_Score (40%)

AI_Benefit_Score = L1 × W1 + L2 × W2 + L3 × W3
```

The weights (W1, W2, W3) aren't fixed — they shift based on market conditions. More on that later. But the base case splits them roughly equally: 30% / 30% / 40%, with a slight emphasis on Layer 3 because ecosystem positioning tends to be the most predictive of long-term returns.

### Layer 1: Revenue Exposure (The Receipts)

Layer 1 is the most concrete. It asks: what percentage of this company's revenue comes directly from AI products, services, or infrastructure?

This sounds simple until you try to calculate it. Most companies don't break out "AI revenue" in their earnings reports. NVIDIA does — their data center segment is essentially an AI revenue proxy. But for a company like Microsoft, AI revenue is spread across Azure AI services, Copilot subscriptions, GitHub Copilot, and dozens of smaller products. None of these get their own line item in the 10-K.

The model breaks AI revenue into four categories:

**Direct AI Revenue:** Products or services where AI is the core value proposition. NVIDIA's H100 GPUs, OpenAI's API, Palantir's AIP platform.

**AI-Enabled Revenue:** Existing products enhanced by AI features. Adobe's Creative Cloud with Firefly, Salesforce with Einstein, Microsoft 365 with Copilot. The product existed before AI, but AI meaningfully increases its value (and price).

**AI-Adjacent Revenue:** Products that benefit from AI adoption without containing AI themselves. Data center REITs, semiconductor equipment makers, cloud infrastructure providers. They sell shovels during the gold rush.

**AI-Defensive Revenue:** Revenue protected because AI makes the company's moat deeper. A logistics company using AI for route optimization doesn't sell AI — but AI makes it harder for competitors to match its efficiency.

Each category gets a different multiplier when calculating the Layer 1 score:

```python
category_weights = {
    "direct_ai": 1.0,      # Full credit
    "ai_enabled": 0.7,     # Partial — AI enhances but isn't core
    "ai_adjacent": 0.5,    # Indirect benefit
    "ai_defensive": 0.3    # Protective moat only
}

L1_score = sum(
    revenue_pct[cat] * category_weights[cat] 
    for cat in categories
) * 100
```

A company with 50% direct AI revenue scores 50. A company with 80% AI-adjacent revenue scores 40. This prevents the model from overweighting companies that sell tangential products to AI buyers while underweighting companies building the core technology.

### Getting the Data Right

Here's where most scoring models fall apart: garbage in, garbage out. Companies don't report AI revenue breakdowns, so every number involves some estimation. The research agents use a data quality grading system that forces transparency about uncertainty.

Every data point in a research report gets a letter grade:

| Grade | Source | Reliability |
|-------|--------|------------|
| A | SEC filings, audited financials, government statistics | Legal verification, manipulation-resistant |
| B | IR materials, earnings calls, official management statements | Company-official, periodically updated |
| C | Reputable industry reports (Gartner, IDC), major news outlets | Third-party research, some estimation |
| D | Analyst estimates, industry insider commentary | Expert opinion, uncertainty exists |
| F | Rumors, unverified reports, speculation | Cannot confirm, weak evidence |

The model enforces minimum quality thresholds:

- Core investment thesis: Only Grade A or B data
- AI scoring layers: At least 50% Grade C or above per layer
- Financial analysis: 80%+ Grade A data
- Risk analysis: Grade D allowed but must be labeled
- Grade F data: Capped at 10% of total inputs

This isn't academic perfectionism. During testing, I found that research agents without quality constraints would confidently cite "AI revenue growth of 40%" based on a single analyst's blog post. The grading system forces them to admit when they're guessing — and the scoring model discounts uncertain inputs accordingly.

The weighted reliability score for each research report:

```
Reliability = (A_share × 1.0) + (B_share × 0.9) + (C_share × 0.8) + 
              (D_share × 0.7) + (F_share × 0.5)
```

Reports scoring below 0.75 get flagged for additional verification. Below 0.65, the report gets rejected and the agent has to start over with better sources.

### Layer 2: Operational Integration (The Competitive Edge)

Layer 2 measures how deeply AI is embedded in a company's operations and whether that creates sustainable competitive advantages.

Revenue exposure (Layer 1) captures the demand side — "people want to buy AI from this company." Operational integration captures the supply side — "this company uses AI to operate better than competitors."

The distinction matters because some of the biggest AI beneficiaries won't sell AI products at all. A retail company that uses AI for demand forecasting, inventory optimization, and personalized marketing doesn't appear in any "AI stocks" ETF. But if AI reduces its operating costs by 15% while competitors are still running on spreadsheets, the stock is absolutely an AI beneficiary.

Layer 2 evaluates five dimensions:

**Process Automation Depth.** How many core business processes use AI, and how mission-critical are they? A company using AI for customer service chatbots scores lower than one using AI for core manufacturing quality control.

**Data Advantage.** Does the company have proprietary data that makes its AI better than competitors'? This is the real moat. Anyone can fine-tune a model. Not everyone has 20 years of proprietary transaction data to train it on.

**AI Talent Density.** What percentage of the engineering team works on AI/ML? Are they publishing research? Winning Kaggle competitions? Getting poached by OpenAI? (That last one is actually a bullish signal — it means the talent is real.)

**Integration Maturity.** Is AI a pilot project or production infrastructure? Companies in the "we're exploring AI" phase score near zero. Companies running AI in production at scale across multiple business units score high.

**Competitive Gap.** How far ahead is this company versus peers in AI adoption? Being early matters, but only if it translates to measurable operational superiority.

Each dimension scores 0-20, and the sum gives the Layer 2 score (0-100).

### Layer 3: Ecosystem Positioning (The Strategic View)

Layer 3 is the most forward-looking and the hardest to quantify. It asks: where does this company sit in the AI ecosystem, and how does that position evolve over the next 2-5 years?

The AI ecosystem has a clear value chain, and position in that chain determines pricing power, margin structure, and vulnerability to disruption:

**Infrastructure Layer (highest margins, highest capital requirements):** Chip designers (NVIDIA, AMD, custom silicon), foundries (TSMC, Samsung), cloud providers (AWS, Azure, GCP). These companies set prices because everything else depends on them.

**Platform Layer (strong network effects, winner-take-most):** Model providers (OpenAI, Anthropic, Google DeepMind), development frameworks (Hugging Face, LangChain), deployment platforms. Network effects create natural monopolies.

**Application Layer (largest market, most competition):** Vertical AI solutions, AI-enhanced SaaS, AI-native startups. Huge addressable market but lower barriers to entry.

**Enabler Layer (indirect but essential):** Data providers, consulting firms, integration specialists, security companies. They don't build AI but they're necessary for AI adoption.

Layer 3 scoring evaluates:

- **Value chain position** — Higher in the stack generally means more pricing power
- **Switching costs** — How painful is it for customers to leave?
- **Network effects** — Does usage by one customer make the product better for others?
- **Data flywheel** — Does the product generate data that improves the AI, creating a compounding advantage?
- **Platform dependency risk** — How vulnerable is the company to platform changes? (Building on OpenAI's API is a dependency risk. Building on open-source models is less so.)

This layer was originally the most subjective part of the model. In v2.1, I added explicit calculation formulas for each sub-dimension to reduce analyst discretion. For example, switching cost scores are now derived from measurable factors like contract length, data migration complexity, and integration depth — not an analyst's gut feeling about "stickiness."

## Dynamic Weighting: The Model That Adapts

Here's where the model gets interesting. The layer weights aren't static. They shift based on market conditions, because what matters most about AI exposure changes depending on the economic environment.

During an AI bubble, when AI stocks are trading at 40x earnings on growth promises alone, you want to emphasize Layer 1 (actual revenue) and discount Layer 3 (future positioning). The market is already pricing in the future; you want to anchor on the present.

During a recession, current profitability matters most. Layer 2 (operational efficiency from AI) becomes the key differentiator because companies that use AI to cut costs survive downturns better.

During a recovery, the future opens up again. Layer 3 (ecosystem positioning) gets maximum weight because the market rewards companies positioned for the next growth cycle.

The regime detection system:

```python
def detect_market_regime():
    vix = get_current_vix()
    ai_sector_pe = get_ai_sector_valuation()
    gdp_growth = get_gdp_growth_rate()
    
    if ai_sector_pe > 40:
        return "AI_BUBBLE"
    elif gdp_growth < 0:
        return "RECESSION"  
    elif vix > 30:
        return "HIGH_VOLATILITY"
    elif gdp_growth > 3:
        return "RECOVERY"
    else:
        return "NORMAL"
```

And the corresponding weight adjustments:

| Regime | L1 Weight | L2 Weight | L3 Weight | Logic |
|--------|-----------|-----------|-----------|-------|
| Normal | 0.30 | 0.30 | 0.40 | Balanced, slight future tilt |
| AI Bubble | 0.45 | 0.30 | 0.25 | Show me the revenue |
| Recession | 0.35 | 0.40 | 0.25 | Efficiency saves you |
| Recovery | 0.20 | 0.25 | 0.55 | Position for growth |
| High Volatility | 0.40 | 0.35 | 0.25 | Certainty premium |

This means the same company can have meaningfully different scores depending on the macro environment. NVIDIA in a normal market might score 85. In an AI bubble regime, if its revenue justifies the valuation, it might score 88. If the revenue growth slows while the sector PE stays at 45, it might drop to 72 as the model demands more concrete evidence and discounts positioning.

The regime detection runs automatically. When VIX spikes above 30, the model doesn't wait for a human to decide "we should be more conservative." It just shifts the weights.

## The Quant Score (The Other 40%)

The AI Benefit Score only accounts for 60% of the final score. The remaining 40% comes from a quantitative overlay that captures factors the AI-specific layers miss:

**Momentum (multi-horizon).** The momentum model uses three time horizons — 1-month, 3-month, and 12-month — with cross-asset signals and regime sensitivity. In backtesting over 10 years, this model produced a [CAGR of 15.52% with a Sharpe ratio of 0.91](https://github.com/openclaw/openclaw). Those numbers aren't cherry-picked; they include the 2020 crash, the 2022 bear market, and the 2024-2025 AI rally.

**Valuation Sanity Check.** A company can score 95 on AI benefit and still be a terrible investment if it's trading at 100x forward earnings. The quant score includes relative valuation metrics — P/E vs. sector, P/S vs. growth rate, EV/EBITDA vs. history — that penalize overvaluation.

**Quality Factors.** Return on equity, free cash flow margins, debt ratios. AI positioning means nothing if the company goes bankrupt before the AI thesis plays out.

**Liquidity and Tradability.** Average daily volume, bid-ask spreads, market cap floors. The model doesn't score companies we can't actually trade efficiently.

The quant score ensures that the portfolio doesn't become a "buy the most AI-exposed stocks at any price" strategy. It forces discipline: AI exposure gets you on the list, but valuation and quality determine how much capital you get.

## The Research Pipeline: How Agents Actually Score Stocks

The scoring model is a framework. The research agents are the ones who actually fill in the numbers. Here's how that pipeline works in practice.

Each research session focuses on one or two stocks maximum. The research agents operate under strict rules derived from institutional research standards:

**Depth over breadth.** Every stock analysis must be equivalent to at least two pages of A4 content. Surface-level analysis ("NVIDIA is the leader in AI chips") gets rejected. The agent has to dig into specific product lines, customer concentration, supply chain dependencies, and competitive dynamics.

**Mandatory bear cases.** Every stock requires at least three bear case scenarios with probability estimates and impact assessments. Each AI scoring layer needs at least one counter-argument. A research report without bear cases is considered incomplete and can't be submitted to the investment team.

**Steel-manning.** Before presenting the bull case, the agent must construct the strongest possible bear case and then explain why the bull case survives it. This was added in v2.2 after I noticed agents producing uniformly bullish research — classic confirmation bias, but automated.

Here's a simplified version of the research prompt that produces this output:

```markdown
## Research Task

Analyze [STOCK] for AI benefit scoring.

### Requirements
1. Layer 1: Calculate AI revenue exposure using the 4-category framework
   - Direct AI, AI-Enabled, AI-Adjacent, AI-Defensive
   - Source every number. Grade every data point (A-F).
   
2. Layer 2: Evaluate operational AI integration
   - Process automation, data advantage, AI talent, 
     integration maturity, competitive gap
   - Score each dimension 0-20 with evidence
   
3. Layer 3: Map ecosystem positioning
   - Value chain position, switching costs, network effects,
     data flywheel, platform dependency
   - Use quantified formulas from v2.1 specification
   
4. Bear Cases (MANDATORY — report rejected without these)
   - Minimum 3 bear scenarios with probability + impact
   - 1 counter-argument per AI layer minimum
   - Early warning signal for each bear case
   
5. Data Quality
   - Grade every data point A through F
   - Calculate report reliability score
   - Flag if below 0.75 threshold
```

When this prompt runs, the research agent typically produces 3,000-5,000 words of analysis per stock. The scoring dimensions get explicit numerical values with sourced justifications. The investment team agents then validate the scores against their own models before anything enters the portfolio.

## Early Warning Signals: Knowing When Scores Go Stale

A scoring model is only useful if it stays current. The v2.1 model includes real-time accuracy tracking that monitors whether past scores predicted actual stock performance.

Every quarter, the system runs a retrospective:

- Did high-scoring stocks outperform low-scoring stocks?
- Which layer had the best predictive power?
- Were there systematic biases (e.g., consistently overscoring semiconductor companies)?

If the model's hit rate drops below threshold, the system flags it and the quant agent investigates. This feedback loop is what distinguishes a scoring model from a one-time ranking. Rankings go stale. Models with feedback loops improve.

The early warning signals for individual stocks are even more practical. Each bear case in a research report specifies a "tripwire" — a specific, measurable event that would invalidate the bull thesis. For example:

- "If NVIDIA's data center revenue growth drops below 20% YoY for two consecutive quarters, the L1 score drops by 15 points."
- "If this company's AI talent retention falls below 80% (measured by LinkedIn data), the L2 score needs immediate review."
- "If the primary customer represents more than 50% of AI revenue, the L3 platform dependency risk increases by 10 points."

These tripwires get monitored automatically. When one fires, the stock gets flagged for re-research before the next rebalancing cycle.

## What This Looks Like in Practice

Let me walk through a concrete example. Say the system is evaluating a Korean semiconductor company — let's call it Company K.

**Layer 1 Analysis:**
- Direct AI revenue: 25% (HBM memory chips for AI training) — sourced from Q3 earnings call [Grade B]
- AI-enabled revenue: 10% (conventional memory with AI-optimized specifications) — estimated from product catalog analysis [Grade C]
- AI-adjacent revenue: 15% (legacy chips used in data center infrastructure) [Grade C]
- L1 Score: (0.25 × 1.0 + 0.10 × 0.7 + 0.15 × 0.5) × 100 = 39.5

**Layer 2 Analysis:**
- Process automation: 14/20 (AI-driven quality control in fabs, predictive maintenance)
- Data advantage: 16/20 (decades of proprietary manufacturing yield data)
- AI talent density: 12/20 (growing AI division but competing with hyperscalers for talent)
- Integration maturity: 15/20 (AI in production for yield optimization, expanding to design)
- Competitive gap: 13/20 (ahead of domestic peers, behind TSMC in AI-driven manufacturing)
- L2 Score: 70

**Layer 3 Analysis:**
- Value chain position: High (memory is essential infrastructure)
- Switching costs: Moderate (qualification cycles are long but not unique)
- Network effects: Low (memory is a commodity with limited network effects)
- Data flywheel: Moderate (manufacturing data improves yield, which improves margins)
- Platform dependency: Low (sells to all major customers)
- L3 Score: 62

**In a normal regime (W1=0.30, W2=0.30, W3=0.40):**
```
AI_Benefit_Score = 39.5 × 0.30 + 70 × 0.30 + 62 × 0.40 = 57.7
```

**In a recovery regime (W1=0.20, W2=0.25, W3=0.55):**
```
AI_Benefit_Score = 39.5 × 0.20 + 70 × 0.25 + 62 × 0.55 = 59.5
```

The score shifts by less than 2 points between regimes because this company has relatively balanced exposure. A pure-play AI company with high L3 but low L1 would see much larger swings — exactly the kind of volatility the dynamic weighting is designed to manage.

Add the quant score (let's say 28/40 based on strong momentum and reasonable valuation), and the final score is 85.7 in normal conditions. That's well above the 65-point threshold for inclusion in the portfolio, meaning the investment team would consider an overweight position.

## Lessons from Building the Model

Three things I learned that weren't obvious when I started:

**Layer separation prevents double-counting.** Early versions of the model had overlapping criteria between layers. A company's "AI revenue" (L1) and "AI product competitiveness" (L3) were measuring similar things from different angles, inflating scores for pure-play AI companies. Strict layer definitions with non-overlapping criteria fixed this.

**Data quality enforcement is the most important feature.** Without the grading system, research agents produce confidently wrong analysis. They'll cite a two-year-old market share estimate as current fact, or treat an analyst's speculative price target as a data point. The quality grades don't eliminate errors, but they make errors visible.

**Dynamic weighting prevents the model from being a one-trick pony.** A static model that always prioritized AI revenue would have underperformed during the 2025 correction when high-revenue AI stocks sold off hardest. The regime-adaptive weights would have shifted toward operational efficiency (L2) and penalized overvalued pure-play names.

## What's Next

The scoring model is the brain of BlackJyong. But a brain without hands can't do anything. In Part 4, I'll cover the **research agent pipeline in detail** — the actual prompt engineering, the workflow from initial screening to final score submission, and the quality control system that catches bad analysis before it reaches the investment team.

If you're building any kind of AI-driven analysis system, the research pipeline post will be the most directly actionable one in this series. The prompts are real, the failure modes are documented, and the iteration process is something you can replicate.

---

*This is Part 3 of the [Building BlackJyong](/series/building-blackjyong/) series. Previous: [Part 2 — 21 Agents, One Portfolio](/posts/series/blackjyong/02-21-agents-tilted-index/). The system described here is a real project running on [OpenClaw](https://github.com/openclaw/openclaw) with automated research agents executing daily via Telegram.*
