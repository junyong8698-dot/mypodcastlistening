---
title: "I Lost 40% of My Savings on Emotional Trades. So I Built an AI Agent to Trade For Me."
date: 2026-03-01T09:00:00+09:00
draft: false
description: "After a devastating 4AM liquidation, I decided to remove myself from the trading loop entirely. This is Part 1 of how I built OWUW Beat — an autonomous BTC trading system powered by AI agents."
tags: ["bitcoin", "algorithmic trading", "AI agents", "OpenClaw", "automation", "quant trading"]
categories: ["OWUW Beat Series"]
series: ["Building OWUW Beat"]
weight: 1
cover:
  image: "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=1200"
  alt: "Bitcoin trading chart on screen"
  caption: "Photo by Unsplash"
ShowToc: true
TocOpen: true
---

## The 4AM Wake-Up Call That Changed Everything

It was February 2025. My phone buzzed at 4:17 AM. Binance liquidation alert. I watched $13,000 evaporate in eleven minutes.

I wasn't a bad trader — at least, I didn't think I was. I'd read the books. I understood regime-based positioning, macro correlations, risk management frameworks. I could articulate exactly why overleveraged longs get crushed in a rising-rate environment.

None of that mattered at 4AM. My hands were shaking. I opened the app and did exactly what I knew I shouldn't do: I averaged down into a falling position. By 5AM, I was down 40% of my total portfolio.

The worst part wasn't the money. It was the clarity that came after. I *knew* the right move. I had the framework. I had the data. And I still made the emotional choice. Every single time.

That morning, sitting in my apartment with half a bottle of soju and a Binance app showing a number I couldn't look at, I made a decision: **I would never make another trade myself.**

Not because I'd stop trading. Because I'd build something that could do it without the 4AM panic, without the sunk-cost averaging, without the dopamine hit of a green candle making me go all-in.

I'd build an AI agent.

## What This Series Covers

Over 10 posts, I'm going to walk through exactly how I built **OWUW Beat** — an autonomous Bitcoin trading system that:

- Monitors BTC markets 24/7 across 5 data categories (on-chain, derivatives, sentiment, macro, technical)
- Makes regime-based allocation decisions (BULL/NEUTRAL/BEAR)
- Runs its own R&D department — testing 15-20 new strategy hypotheses per day
- Has a 9-member AI board of directors that votes on strategy changes every Sunday
- Executes trades on Binance automatically, including Flexible Earn for idle USDT
- Reports everything to me via Telegram — I just read the updates

This isn't a tutorial for a toy project. This is a production system managing real money. I'll share the actual architecture, the real failures, and the prompts I use to run each component.

**Here's the series roadmap:**

| Part | Topic |
|------|-------|
| 1 (this post) | Why I built it — the emotional trading problem |
| 2 | Choosing the stack: OpenClaw, Telegram, Binance API |
| 3 | The first agent — regime detection and allocation logic |
| 4 | Data collection hell — on-chain, derivatives, sentiment, macro, Google Trends |
| 5 | The R&D agent — automated strategy research |
| 6 | The AI board of directors — governance and voting |
| 7 | Dashboard — building the 7-tab control center |
| 8 | Rebalancing automation and Binance Flexible Earn |
| 9 | What went wrong — failures, bugs, and lessons |
| 10 | Results after 60 days — performance, cost, and what I'd change |

## The Core Problem: Humans Are Terrible Traders

Let me be specific about why emotional trading fails, because understanding this is the entire motivation for the system.

### The data is clear

According to Dalbar's 2024 Quantitative Analysis of Investor Behavior ([source](https://www.dalbar.com/QAIB/Index)), the average equity investor earned 5.50% annually over 30 years while the S&P 500 returned 10.15%. The gap is almost entirely behavioral — panic selling, FOMO buying, and timing mistakes.

In crypto, it's worse. A 2023 study by the Bank for International Settlements ([BIS Working Paper 1049](https://www.bis.org/publ/work1049.htm)) found that the majority of retail crypto traders lose money, with losses concentrated around high-volatility events — exactly the moments when emotions run hottest.

My own trading journal confirmed the pattern:

```
Date        Action          Reason              Result
2024-11-15  Bought BTC      "It's going to 100K" -8% (sold panic 3 days later)
2024-12-20  Sold all        "Macro looks bad"    Missed 22% rally
2025-01-08  3x leveraged    "Bottom is in"       Liquidated at 4AM
2025-02-03  Averaged down   "It can't go lower"  Lost additional 15%
```

Every trade had a *reason*. Every reason was an emotion wearing a rational costume.

### The behavioral loop

Here's the pattern I identified in my own behavior:

1. **See price move** → emotional reaction (fear or greed)
2. **Rationalize** → find data that supports the emotion
3. **Act** → trade based on the rationalized emotion
4. **Outcome** → if loss, repeat from step 1 with stronger emotion

This is textbook confirmation bias combined with loss aversion ([Kahneman & Tversky, 1979](https://doi.org/10.2307/1914185)). The fix isn't better analysis — I already had good analysis. The fix is **removing the human from the loop**.

## Why an AI Agent, Not Just a Trading Bot

You might ask: why not just write a Python script with simple rules? Buy when RSI < 30, sell when RSI > 70, done.

I tried that. The problem is markets aren't static. A mean-reversion signal that works in a range-bound market will destroy you in a trending market. Static rules break when regimes change.

What I needed was something that could:

1. **Assess the current market regime** — is this a trending market, a range-bound market, or a high-volatility crisis?
2. **Adapt its strategy** — shift allocation based on the regime, not fixed rules
3. **Research new approaches** — test whether adding new data sources (on-chain metrics, derivatives data, Google Trends) improves performance
4. **Govern itself** — have a structured process for adopting or rejecting strategy changes, so it doesn't overfit to recent data

A Python script can do #1. An AI agent system can do all four.

The key distinction is **agency** — the ability to observe, decide, and act autonomously, and to improve over time. This is what separates an "AI trading bot" from an "AI trading agent."

### The agent architecture (preview)

Here's what I ended up building. I'll detail each component in later posts:

```
┌─────────────────────────────────────────────┐
│              OWUW Beat System                │
│                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │  Daily    │  │   R&D    │  │   Board  │  │
│  │  Market   │  │  Agent   │  │  Meeting │  │
│  │  Report   │  │ (Mon-Fri)│  │  (Sun)   │  │
│  │  (07:00)  │  │ 08-19:00 │  │  18:00   │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  │
│       │              │              │        │
│       v              v              v        │
│  ┌──────────────────────────────────────┐   │
│  │        Regime Detection Engine        │   │
│  │   7 macro factors + technical + on-   │   │
│  │   chain + derivatives + sentiment     │   │
│  └──────────────┬───────────────────────┘   │
│                 │                             │
│                 v                             │
│  ┌──────────────────────────────────────┐   │
│  │     Allocation Decision (0-100%)      │   │
│  │     BULL: 80-100% | NEUTRAL: 30-50%  │   │
│  │     BEAR: 0-20%                       │   │
│  └──────────────┬───────────────────────┘   │
│                 │                             │
│                 v                             │
│  ┌──────────────────────────────────────┐   │
│  │     Binance Execution + Earn          │   │
│  │     Auto-rebalance every 10 days      │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │     Dashboard (7 tabs) + Telegram     │   │
│  └──────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

## The Prompt That Started Everything

Here's the actual first prompt I used when I sat down to build this system. I'm sharing it because I think the *framing* of how you talk to an AI agent matters enormously:

```markdown
I want to build an autonomous Bitcoin trading system. Here's my situation:

1. I lost 40% of my portfolio on emotional trades
2. I have quantitative knowledge but can't execute without emotions interfering
3. I want a system that:
   - Assesses market regime (bull/neutral/bear) using multiple data sources
   - Decides BTC allocation percentage based on regime
   - Executes trades on Binance automatically
   - Reports to me via Telegram daily
   - Has a research component that tests new strategies
   - Has a governance process so strategy changes aren't random

My tech: Mac Mini (M4), Python, Binance API, Telegram bot.
My capital: Small ($34 USDT to start — I want to prove the system works 
before adding more).
My philosophy: I'd rather miss gains than take catastrophic losses. 
Risk-adjusted returns > absolute returns.

Let's start with the architecture. What components do we need, 
and what's the build order?
```

Notice what this prompt does:

- **States the problem honestly** — not "I want to get rich," but "I can't control my emotions"
- **Sets constraints** — small capital, specific tech stack, risk-averse philosophy
- **Asks for architecture first** — not code, not a quick fix, but a system design
- **Defines success criteria** — risk-adjusted returns, not absolute gains

This prompt led to the architecture above, which I then built piece by piece over two weeks.

## What's Next

In Part 2, I'll cover the technology stack decisions — why I chose OpenClaw as the agent framework, how the Telegram integration works, and the Binance API setup process (including the surprisingly annoying API key permission issues).

I'll also share the first working version of the daily market report — the very first automated output that replaced my 4AM phone-checking habit.

---

*This is Part 1 of a 10-part series on building an autonomous BTC trading system. Follow the [OWUW Beat Series](/series/building-owuw-beat/) for updates.*

*Have questions? I read every comment. If you're building something similar, I'd genuinely like to hear about it.*
