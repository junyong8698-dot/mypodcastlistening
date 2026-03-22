---
title: "How I Built a 9-Member AI Board to Govern My Trading Model"
date: 2026-03-23T00:00:05+09:00
draft: false
description: "Inside the weekly governance system where 9 AI directors — progressive, conservative, and moderate — debate and vote on trading model changes with real deliberation."
tags: ["AI governance", "board of directors", "BTC trading", "autonomous agents", "quantitative trading", "OpenClaw", "decision making"]
categories: ["OWUW Beat Series"]
series: ["Building OWUW Beat"]
weight: 6
cover:
  image: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=1200"
  alt: "Business meeting around a conference table with documents"
  caption: "Photo by Unsplash"
ShowToc: true
TocOpen: true
---

## The Problem with Solo Decision-Making

In the [previous post](/series/building-owuw-beat/05-rd-research-agent/), I described the R&D agent that runs experiments autonomously — 22 per day, testing new factors, strategies, and parameter combinations against the production model. By week two, it had generated over 100 experiments. Some showed genuine promise. A few showed backtest results that made my heart rate spike.

And that's exactly where things get dangerous.

When you're a solo operator running a quantitative trading system, you are the researcher, the risk manager, the compliance officer, and the CEO. You find an exciting result at 11 PM, you get excited, and you deploy it at 11:30 PM. There's nobody to ask "are you sure?" Nobody to point out that your out-of-sample test period is suspiciously short, or that your parameter sensitivity analysis has a gap, or that the 2017 Bitcoin rally is doing all the heavy lifting in your backtest.

I've been in finance long enough to know what happens when one person controls research, risk, and deployment. It never ends well. Hedge funds have investment committees for a reason. Banks have risk governance frameworks. Even the most brilliant portfolio manager in the world answers to somebody.

So I built a board of directors. Nine of them. All AI. And they turned out to be more rigorous than most human boards I've sat through.

## Why Not Just Use Hard Rules?

Before I explain the board system, let me address the obvious question: why not just set hard criteria and auto-approve anything that passes?

I tried that first. The R&D Framework v3 established six quantitative adoption criteria that any proposed model change had to pass:

1. **Bootstrap Sharpe 95% CI lower bound > 0.5** — statistical confidence the Sharpe ratio isn't a fluke
2. **Monte Carlo MDD 95th percentile < -40%** — worst-case drawdown under simulated stress
3. **Period independence** — positive returns both with and without the 2017 Bitcoin rally
4. **CAGR at least equal to current model** — no regression on raw performance
5. **Out-of-sample Sharpe > 0.3** — 70/30 train/test split validation
6. **Parameter sensitivity within 20%** — core parameters perturbed ±30% shouldn't tank performance

These criteria are genuinely useful. They filter out the obvious garbage — overfitted strategies, data-mined artifacts, strategies that only work because of one anomalous year. When V5.3 was proposed, it passed all six with comfortable margins: Bootstrap Sharpe CI of [1.83, 3.04], Monte Carlo MDD of -26.3%, out-of-sample Sharpe of 1.71.

But passing all six criteria doesn't mean a strategy is good. It means it's not obviously bad. There's a massive difference.

Quantitative criteria can't evaluate:

- **Whether the improvement is worth the added complexity.** V5.3 added three new parameters (crash threshold, urgency overlay, volatility targeting) to V5.1's two-factor model. Is the MDD improvement from -61.5% to -13.6% worth tripling the parameter count?
- **Hidden dependencies in the data.** V5.3 returns +17,921% with 2017 data and +1,371% without it. Both are positive (criterion 3 passes), but the 13x gap is concerning. Does the strategy depend too heavily on one extraordinary year?
- **Practical implementation risks.** More parameters mean more things that can break. More data sources mean more points of failure. A model that looks great in backtest might be operationally fragile.
- **Whether to deploy now or wait.** Sometimes the right answer is "this looks promising, but let's see another month of out-of-sample data before committing."

These are judgment calls. Qualitative assessments that require weighing competing priorities. Hard rules can't make them. But a board can.

## Designing the Board

The board has nine members, split into three factions of three:

| Faction | Members | Role |
|---------|---------|------|
| Progressive (진보) | Members 1-3 | Favor innovation, growth potential, rapid adoption |
| Conservative (보수) | Members 4-6 | Prioritize risk management, stability, data skepticism |
| Moderate (중도) | Members 7-9 | Balance growth and risk, focus on quantitative evidence |

This faction structure isn't arbitrary. It mirrors the actual tension in any investment decision: the desire to capture upside (progressive), the fear of blowing up (conservative), and the attempt to make evidence-based decisions without emotional bias (moderate).

Every member receives the same information package before deliberation:

- The full R&D proposal with backtest results
- All six criteria evaluations with specific numbers
- Ablation analysis (what happens when you remove each component)
- Parameter sensitivity analysis
- Walk-forward validation results by year
- The R&D agent's own assessment and confidence level
- Current production model performance for comparison

Then each member independently analyzes the proposal, evaluates the evidence, raises specific concerns, and casts a vote with a written justification. Approval requires a simple majority: 5 of 9.

## The Weekly Cycle

The governance system runs on a weekly cadence tied to two automated cron jobs:

**Friday 8:00 PM KST — Weekly Proposal Submission**

The R&D agent compiles its week's work into a formal proposal. This isn't just "here's the best experiment." It's a structured document that includes:

- The proposed model specification with all parameters
- Full backtest results against the six criteria
- Comparison against the current production model
- A combination matrix showing how different parameter values interact
- The agent's own recommendation and confidence level (LOW, MEDIUM, or HIGH)
- Known limitations and concerns

The proposal format matters. I spent time designing it to force the R&D agent to be honest about what it found. Including a confidence level and "known limitations" section means the agent can't just cherry-pick the best numbers. When V5.1 was proposed, the R&D agent rated its confidence as MEDIUM and explicitly noted that the 2025 walk-forward period showed a slightly negative Sharpe. That honesty gave the board useful information.

**Sunday 6:00 PM KST — Board Deliberation**

The board convenes automatically. Each of the nine members reads the proposal, analyzes it from their faction's perspective, evaluates each of the six criteria, and writes a detailed assessment. Then they vote.

Here's what a real deliberation looks like. This is from the V5.1 approval vote on February 22, 2026:

**Progressive Member 1** analyzed the numbers and noted that total return improved from +522% to +627% with Sharpe improving from 1.04 to 1.31. Their key evidence: when you remove the Cu/Au ratio from the model, Calmar drops from 1.27 to 0.88 — a 31% collapse that proves the factor is doing real work. Vote: **Approve**.

**Conservative Member 1** flagged that the 2025 walk-forward showed a Sharpe of -0.04. Quote from their deliberation: "The most recent out-of-sample period is negative. A 25% failure rate in walk-forward validation is concerning." Vote: **Reject**.

**Conservative Member 3** raised an operational concern: trade count increased from 65 to 101 (55% more trades), which means higher slippage and transaction costs in live trading. They also questioned whether the commodity data (Cu, Au prices) would remain available through free APIs long-term. Vote: **Reject**.

**Moderate Member 2** directly addressed the conservative concern: "The 2025 walk-forward return of -0.77% is essentially flat. This isn't a catastrophic failure, it's opportunity cost. And V4.1 had a similar rough patch in early 2025." Vote: **Approve**.

Final tally: 7-2 in favor. V5.1 was approved with three conditions:
1. Monthly monitoring of Cu/Au data source reliability
2. Three consecutive months of negative Sharpe triggers an automatic re-review
3. Monitoring gap between backtest and live transaction costs

## A Real Board Meeting: V5.3 Approval

The most interesting board meeting happened on March 1, 2026, when V5.3 was proposed. This was a major upgrade: V5.3 introduced crash defense optimization (faster crash detection by lowering the threshold from -7% to -5%), macro urgency overlay (cutting allocation 30% when regime scores deteriorate rapidly), and bear volatility targeting (reducing position size when 30-day volatility exceeds 30% during bear/neutral regimes).

The headline numbers were dramatic: CAGR jumped from 55.4% to 76.3%, max drawdown improved from -61.5% to -13.6%, and Calmar ratio went from 0.90 to 5.60.

Every member received the full package. Here's how the deliberation unfolded.

The progressive faction was unanimously enthusiastic. Progressive Member 3 made the most compelling case: "V5.1's MDD of -61.5% is lethal for real capital. A 61% drawdown means you need a 157% gain just to get back to break-even. V5.3's -13.6% MDD is the difference between staying in the game and getting wiped out."

The conservative faction split. Conservative Member 1 — who had rejected V5.1 — actually voted to approve V5.3. Their reasoning was striking in its intellectual honesty: "The numbers are almost too good, which makes me suspicious. But the OOS Test Sharpe of 1.71 shows natural Train→Test decay of 36%, which is what you'd expect from a real signal, not an overfitted one. If I set the criteria, I need to abide by them."

Conservative Member 2 was the lone dissenter. Their analysis zeroed in on a genuine weakness: the 13x performance gap between the 2017-included backtest (+17,921%) and the 2017-excluded version (+1,371%). "Both are positive, so criterion 3 technically passes. But a strategy where one year does 13 times the work of the other six years combined has a concentration problem." They preferred a phased approach — deploy the simpler V5.2 first, then upgrade to V5.3 after more live data. Vote: **Reject**.

Conservative Member 3 offered the most nuanced take. They pointed out that the R&D agent had been transparent about V5.3's real source of alpha: "The R&D agent honestly said that urgency and volBear are insurance — they don't change the core alpha. The real change is just two parameters: crash threshold from -7% to -5%, and transition steps from 3 to 2. The fact that this minimal change passes all six criteria is actually evidence of robustness, not complexity."

The moderate faction was unanimous in approval but added conditions. Moderate Member 1 quantified the margins: Bootstrap CI lower bound was 3.6x the threshold. Monte Carlo MDD had 35% headroom. OOS Sharpe exceeded the requirement by 5.7x. "Every criterion has substantial margin. This isn't a borderline pass."

Final vote: 8-1 in favor. Three conditions attached:
1. Three consecutive months of negative Sharpe triggers V5.1 rollback review
2. Monthly Cu/Au data source checks continue
3. Any parameter changes require board re-approval

## What Happens After Approval

When the board approves a new model, the system executes a seven-item automatic update:

1. **model_profile.json** — the production model configuration file
2. **research_agent_task.md** — R&D benchmark updated so future experiments compete against the new model
3. **Dashboard restart** — live display reflects the new model's parameters and backtest results
4. **MEMORY.md** — long-term memory updated with the new model specification
5. **Investment Memorandum** — the formal IM document updated with new stats
6. **Signal calculation** — regime detection thresholds updated
7. **R&D cron payload** — research agent's comparison baseline updated

This automation is critical. Without it, you'd have seven manual steps to execute after every approval, each of which could be forgotten or done incorrectly. I learned this the hard way — after V5.3 was approved, the IM document still referenced V5.2 stats for over a week because the auto-update for that item had a bug.

## Why Factions Matter More Than Unanimous Votes

The most valuable aspect of the board isn't the voting outcome. It's the deliberation process.

When all nine members agree, you learn nothing new. The proposal was obviously good (or obviously bad). The interesting cases are when factions disagree, because the disagreement surfaces risks you hadn't considered.

In the V5.1 vote, Conservative Member 3's concern about increased trade count (65→101 trades over the backtest period) was something I hadn't thought about. In live trading with small capital, each trade incurs exchange fees, potential slippage, and tax events. A 55% increase in trade frequency isn't free. That concern led me to explicitly track live transaction costs against backtest assumptions.

In the V5.3 vote, Conservative Member 2's analysis of the 2017 dependency (13x performance gap) forced me to think seriously about what happens if BTC never has another 2017-style 20x rally. The strategy still works without it (+1,371% over 7 years is still excellent), but the point is valid: much of the headline number comes from one extraordinary year.

These aren't concerns I would have surfaced on my own. When you've spent weeks building something and the backtest shows a Sharpe of 2.43, the last thing you want to hear is "but what about the 2017 dependency?" The board structure forces that conversation to happen.

## The Prompt Engineering Behind Each Faction

Making nine AI board members actually deliberate differently — rather than producing nine variations of the same analysis — requires careful prompt design.

Each faction gets a different system prompt that shapes their analytical lens:

**Progressive members** are instructed to evaluate proposals through the lens of growth potential and competitive advantage. They're told to consider opportunity cost of NOT adopting an improvement. They weight upside potential more heavily than downside risk, but they're not reckless — they still evaluate all six criteria rigorously.

**Conservative members** are instructed to be skeptical by default. They look for hidden risks, question data quality, worry about implementation complexity, and prefer the known over the unknown. They're told to consider what happens in the worst-case scenario, not the expected case. Their job is to find reasons to say no.

**Moderate members** are instructed to focus exclusively on quantitative evidence. They don't have an inherent bias toward action or inaction. They evaluate whether the data supports the conclusion, whether the margins are sufficient, and whether the testing methodology is sound. They're the tiebreakers.

The key insight: you don't want all factions to agree. If the conservatives approve something, that's a strong signal. If the progressives reject something, that's an even stronger signal. The faction structure creates information from disagreement.

Here's the actual structure each member follows in their deliberation:

```
1. Analysis — their interpretation of the data from their faction's perspective
2. Evidence — specific numbers and tests they find most relevant
3. Positives — what they genuinely like about the proposal
4. Concerns — what worries them, even if they plan to vote yes
5. Criteria evaluation — pass/fail assessment for each of the 6 criteria
6. Vote — APPROVE, REJECT, or DEFER
7. Reason — one-sentence justification for their vote
```

This structure prevents lazy deliberation. Every member must find something positive even if they're voting to reject, and every member must raise concerns even if they're voting to approve. This eliminates the rubber-stamp problem where board members just vote yes without thinking.

## Handling Edge Cases

The board system has dealt with several interesting situations:

**When no proposal is ready.** Some weeks, the R&D agent doesn't find anything worth proposing. The weekly proposal cron fires, the agent reviews its experiments, and if nothing passes all six criteria, it submits a "no proposal" report. The board meeting cron still fires but recognizes there's nothing to vote on. This is fine — most weeks in quantitative research produce nothing actionable.

**When the board adds conditions.** Both V5.1 and V5.3 were approved with conditions attached. These conditions aren't just recorded in the minutes — they're monitored. The three-month negative Sharpe trigger for V5.3 means the system tracks monthly Sharpe ratios and would automatically schedule a re-review if three consecutive months come in negative.

**When the CEO overrides.** On March 17, 2026, the CEO issued a directive: stop all R&D. V5.3 was to be the final model. No more experiments, no more proposals, no more board meetings. The R&D cron was disabled, the weekly proposal cron was disabled, and the board meeting cron was disabled. The governance system respected this override — it exists to serve the operator, not to run autonomously against their wishes.

This last point is important. The board is a decision-support tool, not an autonomous authority. The CEO can override any decision, disable the entire system, or manually deploy a model that the board rejected. The board exists to provide structured deliberation, not to replace human judgment.

## Implementation Details

The board runs as a single cron job on OpenClaw, scheduled for Sunday 6:00 PM KST. The payload is a structured prompt that:

1. Reads all proposal files from the `research/proposals/` directory
2. Identifies the most recent unreviewed proposal
3. Generates nine independent deliberations with faction-specific instructions
4. Tallies votes and determines the outcome
5. If approved, triggers the seven-item auto-update pipeline
6. Saves the full minutes as JSON to `research/proposals/YYYY-MM-DD_minutes.json`
7. Sends a summary to the CEO via Telegram

The entire process — from reading the proposal to completing all updates — takes about 3-5 minutes. The minutes JSON includes every member's full analysis, vote, and reasoning, creating a complete audit trail.

Here's a simplified version of the board meeting prompt structure:

```markdown
You are conducting a board meeting for OWUW Beat trading system.

## Current Production Model
V5.3: Sharpe 2.43, MDD -13.6%, CAGR 76.3%, Calmar 5.60

## 6 Adoption Criteria
[criteria listed with specific thresholds]

## This Week's Proposal
[proposal content injected here]

## Board Composition
9 members: 3 Progressive, 3 Conservative, 3 Moderate
Each member must provide:
- Independent analysis from their faction perspective
- Specific evidence citations
- Positives and concerns
- Individual criterion evaluation
- Vote with justification

## Voting Rules
- Simple majority (5/9) required for approval
- Conditions may be attached to approval
- DEFER option available if more data needed
```

The minutes are stored as structured JSON, which means they're queryable. I can ask "which member has voted against the most proposals?" or "what concerns has the conservative faction raised across all meetings?" This creates institutional memory — the board learns from its own history.

## What I Learned

After running this system for several weeks and three major votes (V5.1 approved 7-2, V5.2 approved 7-2, V5.3 approved 8-1), here's what surprised me:

**The conservatives made me money.** Not by blocking good proposals — they approved two of three — but by attaching conditions that caught real problems. The Cu/Au data monitoring condition caught a temporary API outage that would have corrupted the regime signal. The transaction cost monitoring revealed that live slippage was 40% higher than the backtest assumed. These catches happened because a conservative board member raised the concern, not because I was looking for it.

**Faction disagreement is signal.** When V5.1 passed 7-2, the two conservative dissenters both cited the 2025 walk-forward weakness. That concern was valid — it just wasn't sufficient to override the overall improvement. But tracking it meant I was watching the right metric when V5.3 addressed it directly.

**Transparency compounds.** The R&D agent's honesty about V5.3 (admitting that urgency and volBear were "insurance" rather than core alpha generators) actually increased the board's confidence. Several members cited this transparency as evidence that the proposal wasn't overselling itself. Building a system that rewards honesty creates a virtuous cycle.

**The system is only as good as its criteria.** When V5.3 showed a 13x performance gap with and without 2017 data, criterion 3 ("positive returns both ways") technically passed. But the spirit of the criterion — testing for period dependence — wasn't fully captured by a simple positive/negative check. A future version might require the gap to be less than, say, 5x.

## When to Stop

The governance system ran for about four weeks before the CEO shut it down. Not because it failed — V5.3 was performing well in live trading — but because the CEO decided that the model was good enough and further optimization wasn't worth the operational complexity.

This is a legitimate decision. Every system has a point of diminishing returns. V5.3's Sharpe of 2.43 and MDD of -13.6% represented a massive improvement over V5.1. The marginal gain from V5.4, V5.5, or V5.6 would likely be small, and each iteration adds complexity and maintenance burden.

The board system now sits dormant, ready to be reactivated if market conditions change enough to warrant model revision. The cron jobs are disabled but not deleted. The criteria are documented. The minutes from all three votes are preserved. If I need to restart the governance process in six months, I can pick up exactly where I left off.

## Build Your Own

If you want to implement a similar governance framework, here's what you need:

**Minimum viable version:**
- One cron job for weekly proposals (R&D agent summarizes findings)
- One cron job for board deliberation (3-5 members are sufficient for smaller systems)
- A structured proposal format that forces honest reporting
- Hard quantitative criteria as a first filter
- JSON-based minutes storage for audit trail

**What to customize:**
- Number of board members (odd numbers to avoid ties)
- Faction composition (you might want different perspectives than progressive/conservative/moderate)
- Voting threshold (simple majority vs supermajority)
- Auto-update pipeline (depends on your system's components)
- Override mechanism (how the human operator can intervene)

**What not to skip:**
- The concerns section in each deliberation. Without it, the board becomes a rubber stamp.
- Conditions on approval. Unconditional approvals lose the nuance that makes governance valuable.
- Structured minutes. If you can't query past decisions, you lose institutional memory.

The board of directors system is probably the most unusual thing I've built in OWUW Beat. It's also, unexpectedly, the most valuable. Not because AI governance is better than human governance — it isn't. But because having any structured deliberation process is infinitely better than one person making decisions at 11 PM after seeing an exciting backtest result.

---

*In the [next post](/series/building-owuw-beat/), I'll cover the dashboard — how I built a real-time monitoring interface that connects all of these components (regime detection, R&D, board governance, live performance tracking) into a single view. Including the Electron desktop app, the Flask backend with 36 API endpoints, and the resource deadlock bug that deleted the entire application three times.*

*This is Part 6 of the [Building OWUW Beat](/series/building-owuw-beat/) series.*
