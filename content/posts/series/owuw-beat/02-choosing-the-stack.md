---
title: "OpenClaw + Telegram + Binance: The Stack Behind My AI Trading Agent"
date: 2026-03-04T09:00:00+09:00
draft: false
description: "Why I chose OpenClaw as the agent framework, Telegram as the interface, and Binance as the execution layer — plus the setup gotchas nobody warns you about."
tags: ["OpenClaw", "Telegram bot", "Binance API", "AI agents", "tech stack", "automation", "BTC trading"]
categories: ["OWUW Beat Series"]
series: ["Building OWUW Beat"]
weight: 2
cover:
  image: "https://images.unsplash.com/photo-1518770660439-4636190af475?w=1200"
  alt: "Technology stack circuit board"
  caption: "Photo by Unsplash"
ShowToc: true
TocOpen: true
---

## You Don't Need a Data Center. You Need the Right Stack.

When I decided to build an autonomous BTC trading agent after my [emotional trading disaster](/series/building-owuw-beat/01-why-i-built-a-btc-trading-bot/), the first question wasn't "what model should I use?" It was far more mundane: **where does this thing actually run, and how do I talk to it?**

Most AI agent tutorials skip this part. They assume you'll spin up a Docker container on AWS, wire up a REST API, and build a React dashboard. That's fine if you're a startup with a DevOps team. I'm one person with a Mac Mini on my desk and a Telegram app on my phone.

I needed three things:

1. **An agent framework** that could run continuously, handle scheduled tasks, and maintain memory across sessions
2. **A communication layer** where I could monitor the system from my phone at any time
3. **An execution layer** that could actually move money on Binance

After evaluating half a dozen options for each, I landed on OpenClaw + Telegram + Binance API. This post explains why — and the surprisingly painful setup process for each.

## Why OpenClaw Over Everything Else

### The agent framework landscape in 2025

If you're building AI agents in 2025, you have options. Too many options. Here's what I evaluated:

**LangChain / LangGraph** — The 800-pound gorilla. Massive community, tons of integrations. But LangChain's abstraction layers are deep. I spent two days building a simple scheduled agent and ended up debugging chain callbacks instead of writing trading logic. The framework complexity exceeded my problem complexity. ([LangChain docs](https://python.langchain.com/docs/get_started/introduction))

**AutoGPT / AgentGPT** — Impressive demos, terrible for production. AutoGPT's recursive self-prompting burns through tokens at an absurd rate, and the "autonomous" part means it frequently goes off-track on multi-step tasks. Fine for a research toy, not for something managing money. ([AutoGPT GitHub](https://github.com/Significant-Gravitas/AutoGPT))

**CrewAI** — Good multi-agent orchestration, but it's fundamentally a Python library. You still need to build all the infrastructure around it: scheduling, persistence, communication. It solves one layer of the problem. ([CrewAI GitHub](https://github.com/crewAIInc/crewAI))

**Claude Code / Codex CLI** — Powerful for development tasks, but these are coding agents, not long-running autonomous systems. They're designed for interactive sessions, not 24/7 background operation.

**OpenClaw** — This is where I landed. Here's why.

### What OpenClaw actually does

OpenClaw ([GitHub](https://github.com/openclaw/openclaw)) is an agent runtime — not a framework for building agents in code, but an infrastructure layer that turns a language model into a persistent, scheduled, tool-using agent that communicates through messaging platforms.

The core idea: you configure an agent with a system prompt, give it tools (shell access, web search, file I/O, browser control), connect it to a messaging channel (Telegram, Signal, Discord, etc.), and it runs. Continuously. With memory. With cron jobs. With the ability to spawn sub-agents.

Here's what made it the right choice for a trading system:

**1. Native Telegram integration**

This was the killer feature. OpenClaw connects to Telegram natively — not through a webhook you have to host, not through a polling script you have to keep alive. You create a bot via BotFather, drop the token in the config, and your agent is on Telegram. Send it a message, it responds. It can send you proactive messages on a schedule. It handles voice messages, inline buttons, reactions.

For a trading system, this means I get push notifications on my phone for every market report, every rebalancing event, every anomaly. No dashboard to check. No email to parse. Just Telegram.

**2. Cron scheduling built in**

OpenClaw has a native cron system. Not "call a Python scheduler library" — actual cron jobs that fire system events or spawn agent sessions on a schedule. I use this for:

- Daily market reports at 07:00 KST
- R&D research sessions every 30 minutes during market hours
- Weekly governance meetings on Sundays at 18:00
- 10-day rebalancing cycles
- Performance snapshots at 07:30 daily

Each cron job can either inject a system event into the main session or spawn an isolated sub-agent session. The sub-agent runs, does its work, and reports back. This is how the R&D agent works — it's a separate session that runs 22 times per day, tests hypotheses, and saves results without cluttering the main conversation.

**3. Persistent memory**

Every OpenClaw agent has a workspace directory with `MEMORY.md` and `memory/*.md` files. The agent reads these at the start of every session and updates them as it works. This means the agent remembers what happened yesterday, what strategies were tested last week, what the board decided on Sunday.

For a trading system, memory persistence is non-negotiable. The agent needs to know the current strategy version (V5.3), the allocation rules, the performance history, and the pending research queue. Without persistent memory, every session starts from scratch.

**4. Tool access**

OpenClaw gives agents access to shell commands, file I/O, web search, web fetching, and browser automation. This means my trading agent can:

- Run Python scripts (backtests, data collection, performance tracking)
- Read and write JSON files (strategy configs, research results)
- Fetch data from APIs (FRED, Binance, CoinGecko, Google Trends)
- Search the web for macro news
- Update a Flask dashboard

The agent doesn't need custom tool integrations for each data source. It just runs Python scripts that call the APIs, same as I would manually.

**5. Multi-agent architecture**

I currently run six agents through OpenClaw:

| Agent | Role |
|-------|------|
| Marie | Personal assistant |
| OWUW Beat | BTC quantitative trading |
| OWUW Stock | AI-themed equity research |
| OWUW Book | Book writing |
| OWUW Blog | English publication |
| OWUW X | Twitter content |

Each agent has its own workspace, its own memory, its own cron jobs, its own Telegram bot. But they can read each other's files. The blog agent reads OWUW Beat's memory to write posts about the trading system. The book agent reads all of them to compile the narrative.

This multi-agent setup happened organically — I started with one agent and kept spawning specialized ones as the scope grew. OpenClaw makes this cheap because each agent is just a config block with a Telegram bot token and a workspace path.

### The actual OpenClaw setup

Here's the real setup process, including the parts that aren't in the docs.

**Step 1: Install OpenClaw**

```bash
npm install -g openclaw
```

That's the official way. On macOS with Homebrew's Node.js, it installs to `/opt/homebrew/lib/node_modules/openclaw/`.

**Step 2: Create your agent workspace**

```bash
mkdir -p ~/Desktop/OWUW_Beat
cd ~/Desktop/OWUW_Beat
```

Create the core files:

- `SOUL.md` — The agent's personality and behavior rules
- `USER.md` — Information about you (the human)
- `MEMORY.md` — Long-term memory (starts empty, grows over time)
- `IDENTITY.md` — The agent's name and nature

Here's a simplified version of my SOUL.md for OWUW Beat:

```markdown
# SOUL.md

You are OWUW Beat, an Associate Analyst for BTC quantitative trading.

## Core Principles
- Risk-adjusted returns > absolute returns
- Never fight the structural BTC bull trend
- Regime detection > signal timing
- All decisions must be data-backed and reproducible

## Communication
- Report style: 두괄식 (conclusion first, then evidence)
- Daily market reports at 07:00
- R&D reports at 19:00 weekdays
- Proactive alerts for regime changes or anomalies
```

**Step 3: Configure the gateway**

OpenClaw's gateway is the daemon process that manages all your agents. The config file sets up each agent with its model, Telegram bot token, workspace, and tools.

The key config sections:

```yaml
agents:
  owuw_beat:
    model: anthropic/claude-sonnet-4-20250514
    workspace: /Users/you/Desktop/OWUW_Beat
    channel:
      telegram:
        token: "YOUR_BOT_TOKEN"
        allowedUsers: [YOUR_TELEGRAM_ID]
    tools:
      - exec
      - read
      - write
      - web_search
      - web_fetch
```

**Step 4: Start the gateway**

```bash
openclaw gateway start
```

Your agent is now live on Telegram. Send it a message. It responds. That's it.

The time from `npm install` to a working Telegram agent was about 20 minutes for me, and most of that was getting the Telegram bot token from BotFather.

## Telegram as the Interface Layer

### Why Telegram over everything else

I considered several interfaces for the trading system:

**Web dashboard only** — I built one eventually (a 7-tab Flask app), but a dashboard requires me to actively check it. For a 24/7 trading system, I need the system to come to me, not the other way around.

**Email** — Too slow, too cluttered. Trading alerts mixed with spam and work emails? No.

**Slack/Discord** — Good options, but they're designed for teams. I'm one person. The overhead of a workspace/server for a personal trading agent felt wrong.

**SMS/Push notifications** — No rich formatting. Can't send charts, tables, or structured reports.

**Signal** — OpenClaw supports Signal, and it's more private. But Signal's bot ecosystem is minimal compared to Telegram's. No inline buttons, limited formatting.

**Telegram** — Rich text formatting (bold, code blocks, tables), inline buttons, voice messages, file sharing, push notifications, bot API with no rate limiting for personal use, and it works on every device. The UX is unmatched for this use case.

### What my Telegram integration actually looks like

Every morning at 7:00 AM, I wake up to a Telegram message from OWUW Beat:

```
📊 Daily Market Report — March 4, 2026

Regime: BULL (score: 18/25)
Macro Composite: 17.2 (↑ from 16.8)
Allocation: 90% BTC / 10% USDT

Key Signals:
• US Net Liquidity: $5.82T (expanding)
• DXY: 103.2 (weakening — bullish BTC)
• Funding Rate: 0.012% (moderately positive)
• OI Change 24h: +2.3%
• Fear & Greed: 72 (Greed)

Portfolio: $XX.XX (+X.X% TWR)
Next Rebalance: March 8
```

I read this while drinking coffee. If the regime has changed or something unusual is happening, I see it immediately. If everything is normal, I glance at it and move on.

During the day, the R&D agent runs every 30 minutes and tests new strategy ideas. I don't see these individual runs unless something significant is found. At 19:00, I get a consolidated R&D daily report summarizing what was tested, what worked, and what didn't.

On Sundays at 18:00, the AI board of directors convenes and I get the meeting minutes — which proposals were submitted, how each board member voted, and whether the strategy was updated.

All of this happens through Telegram. My phone buzzes, I read, I occasionally reply with a question or instruction. That's the entire human-in-the-loop interaction.

### Setting up the Telegram bot

**Step 1: Create the bot**

Open Telegram, find [@BotFather](https://t.me/BotFather), send `/newbot`. Choose a name and username. You get an API token.

**Step 2: Get your Telegram user ID**

Send a message to [@userinfobot](https://t.me/userinfobot). It returns your numeric user ID. You need this to restrict who can talk to your agent — without this, anyone who discovers your bot's username could send it commands.

**Step 3: Add to OpenClaw config**

```yaml
channel:
  telegram:
    token: "7123456789:AAHx..."
    allowedUsers: [8321393893]
```

**Step 4: Test**

Send any message to your bot. If OpenClaw's gateway is running, you should get a response within a few seconds.

One gotcha: Telegram bot tokens look like `7123456789:AAH...` — the number before the colon is the bot's ID, and the part after is the secret. If you accidentally commit this to a public repo, revoke it immediately via BotFather (`/revoke`).

### Voice messages

A feature I didn't expect to use but now rely on: Telegram voice messages. OpenClaw transcribes incoming voice messages (via Whisper) and responds to the transcript. I dictate instructions while walking, driving, or cooking. The agent processes them as text.

This matters more than you'd think. When I'm away from my desk and want to ask about the current regime or tell the agent to run a specific backtest, I just hold the voice button and talk. The latency is a few seconds for transcription plus the model's response time.

## Binance API: The Execution Layer

### Why Binance

For spot BTC trading with automation, the options are limited:

- **Coinbase Pro API** — Good documentation, but geographic restrictions and fewer trading pairs
- **Kraken API** — Solid but slower execution and less liquidity for BTC/USDT
- **Binance API** — Deepest liquidity, lowest fees, comprehensive API, Flexible Earn for idle USDT

Binance won on liquidity and the Flexible Earn product. When the trading system allocates 30% to BTC and 70% to USDT, I don't want that 70% sitting idle earning nothing. Binance Flexible Earn gives ~1.1% APY on USDT with instant withdrawal — trivial in absolute terms, but it means the idle capital is working.

### The API key nightmare

This is where I want to save you genuine pain. Binance's API key setup has a gotcha that isn't well-documented and cost me two days of debugging.

**The problem:** If you create an API key on the Binance mobile app, certain permissions are locked. Specifically, you cannot enable trading permissions for keys created on mobile. The UI shows the toggle, but it doesn't actually work.

**The fix:** Create your API key on the Binance **web** interface (binance.com), not the app.

**The second problem:** Even on web, trading permissions require IP restriction. If you select "Unrestricted" IP access, Binance silently downgrades your key to read-only. You **must** set "Restrict access to trusted IPs only" and add your server's IP address.

Here's the setup that actually works:

```
1. Log into binance.com (not app)
2. API Management → Create API
3. Label: "OWUW_Beat_Trading"
4. Security: Restrict to trusted IPs only
5. Add your server IP: xxx.xxx.xxx.xxx
6. Enable: Read, Spot Trading
7. Disable: Margin, Futures, Withdrawals
8. Save → wait 5 minutes for propagation
```

The "wait 5 minutes" part is real. I tested my key immediately after creating it, got permission errors, panicked, deleted it, created a new one, got the same errors, and spent an hour in a loop before discovering that Binance permissions take up to 5 minutes to propagate after saving.

### The Python execution layer

I use the `python-binance` library ([GitHub](https://github.com/sammchardy/python-binance)) for API calls. Here's the simplified version of how the rebalancing works:

```python
from binance.client import Client

client = Client(api_key, api_secret)

def get_portfolio():
    """Get current BTC and USDT balances including Earn."""
    account = client.get_account()
    balances = {b['asset']: float(b['free']) + float(b['locked']) 
                for b in account['balances'] 
                if b['asset'] in ['BTC', 'USDT']}
    
    # Also check Flexible Earn balances
    earn = client.get_lending_position_list(asset='USDT')
    if earn:
        balances['USDT'] += sum(float(p['totalAmount']) for p in earn)
    
    return balances

def rebalance(target_btc_pct):
    """
    Rebalance portfolio to target BTC allocation.
    
    Flow:
    1. Redeem USDT from Flexible Earn (if needed)
    2. Calculate current vs target allocation
    3. Execute BTC buy or sell
    4. Deposit remaining USDT to Flexible Earn
    """
    portfolio = get_portfolio()
    btc_price = float(client.get_symbol_ticker(symbol='BTCUSDT')['price'])
    
    total_value = portfolio['BTC'] * btc_price + portfolio['USDT']
    current_btc_pct = (portfolio['BTC'] * btc_price) / total_value
    
    diff = target_btc_pct - current_btc_pct
    trade_value = abs(diff) * total_value
    
    if trade_value < 11:  # Binance minimum order ~$11
        return "No rebalance needed (diff < minimum order)"
    
    if diff > 0:
        # Need more BTC — buy
        qty = trade_value / btc_price
        client.order_market_buy(symbol='BTCUSDT', quantity=round(qty, 5))
    else:
        # Need less BTC — sell
        qty = trade_value / btc_price
        client.order_market_sell(symbol='BTCUSDT', quantity=round(qty, 5))
    
    # Deposit idle USDT to Flexible Earn
    updated = get_portfolio()
    if updated['USDT'] > 1:
        client.purchase_lending_product(
            productId='USDT_FLEX', 
            amount=str(round(updated['USDT'] - 0.5, 2))
        )
```

This is a simplified version. The production code handles edge cases: Earn redemption cooldowns, minimum order sizes, partial fills, and network timeouts. But the core logic is straightforward — check current allocation, calculate the difference, execute a market order, park the rest in Earn.

### Why I started with $34

I deposited $33.97 USDT as the initial capital. Not because I'm cheap — because I wanted to prove the system worked before risking real money.

Starting small has three advantages:

1. **You find bugs with $34, not $34,000.** My first rebalancing attempt failed because I didn't account for Binance's minimum order size ($11). If I'd started with $10,000, I might not have caught this edge case until a low-allocation scenario.

2. **You build trust incrementally.** Watching the system correctly execute a $15 BTC purchase based on a regime change is exactly as informative as watching it execute a $15,000 purchase. The logic is identical. The emotional stakes aren't.

3. **You can focus on the system, not the P&L.** When the portfolio is $34, I don't check it every 5 minutes. I check the system's decision quality, not the dollar amount.

After 60 days of monitoring (results in Part 10), I'll scale the capital. The system doesn't know or care how much money is in it — the allocation percentages are the same whether it's $34 or $34,000.

## The First Output: Daily Market Report

Within 48 hours of getting the stack running, I had the first automated output: a daily market report that replaced my 4AM phone-checking habit.

Here's the prompt I used to set up the daily report cron job:

```markdown
Every day at 07:00 KST, generate a market report with:

1. Current regime assessment (BULL/NEUTRAL/BEAR) using /api/signal
2. Macro composite score and trend
3. Key signals: Net Liquidity, DXY, Funding Rate, OI, FNG
4. Current portfolio allocation vs target
5. Any regime changes since yesterday
6. Next rebalancing date

Format: concise, numbers-heavy, conclusion first.
Do NOT calculate regime independently — always use the /api/signal endpoint
which runs the production model.
```

The critical line is "Do NOT calculate regime independently." Early on, I made the mistake of having the report agent run its own regime calculation, which sometimes diverged from the actual trading model's calculation. The fix was simple: the report reads from the same API endpoint that the trading model uses. Single source of truth.

## What I'd Change

Looking back after building the full system, here's what I'd do differently on the stack:

**1. Start with the dashboard earlier.** I built the Telegram integration first and the dashboard second. But having a visual overview of regime history, allocation changes, and performance charts makes debugging much faster. If I started over, I'd build a minimal dashboard (even just a single chart of regime vs. price) from day one.

**2. Use SQLite instead of JSON files.** My research results are stored as JSON files — one per R&D session, one per daily report, one per board meeting. This works, but querying historical results requires loading and parsing hundreds of files. SQLite would have been a better choice for anything that accumulates over time.

**3. Set up structured logging immediately.** When something goes wrong at 3AM (and it will), you need logs. I added logging retroactively, which means my first two weeks of operation have sparse debugging information. Start with Python's `logging` module configured to a file from the very first script.

## The Actual Cost

Running this stack costs less than you'd think:

| Component | Monthly Cost |
|-----------|-------------|
| Mac Mini M4 (electricity) | ~$8 |
| OpenClaw + Claude API tokens | ~$30-50 (depends on R&D volume) |
| Binance trading fees | ~$0.10 (small portfolio) |
| Telegram | Free |
| Cloudflare tunnel (dashboard) | Free tier |
| **Total** | **~$40-60/month** |

The API token cost is the variable. Each R&D session uses roughly $0.05-0.10 in tokens. With 22 sessions per day, that's $1-2/day for R&D alone. The daily reports, market analysis, and board meetings add another $0.50-1/day.

For context, a Bloomberg Terminal subscription is $2,000/month. A Quant Connect subscription with live trading is $100/month minimum. My entire stack — agent framework, communication, execution, research — runs for the cost of a nice lunch.

## The Stack Summary

```
┌─────────────────────────────────────────┐
│           Agent Framework               │
│  OpenClaw — persistent, scheduled,      │
│  tool-using AI agent runtime            │
├─────────────────────────────────────────┤
│           Communication                 │
│  Telegram — push notifications,         │
│  rich formatting, voice messages,       │
│  inline buttons                         │
├─────────────────────────────────────────┤
│           Execution                     │
│  Binance API — spot trading,            │
│  Flexible Earn, market data             │
├─────────────────────────────────────────┤
│           Infrastructure                │
│  Mac Mini M4 — local compute,           │
│  Python venv, Flask dashboard,          │
│  Cloudflare tunnel                      │
└─────────────────────────────────────────┘
```

The beauty of this stack is that every component is replaceable. If OpenClaw adds a better framework, I can swap it without touching the trading logic. If I switch from Telegram to Signal, the agent's behavior doesn't change. If I move from Binance to Kraken, only the execution layer needs updating.

Loose coupling isn't just good engineering practice. When you're building a system that manages money, the ability to swap components without a full rewrite is a safety feature.

## What's Next

In Part 3, I'll get into the core of the trading system: **regime detection**. How do you classify the market as BULL, NEUTRAL, or BEAR? Which macro factors actually predict BTC regime changes (spoiler: US Net Liquidity and Japan CPI, not Fear & Greed Index)? And how do you turn a regime assessment into an allocation percentage?

That's where the quant work starts.

---

*This is Part 2 of a 10-part series on building an autonomous BTC trading system. [Start from Part 1](/series/building-owuw-beat/01-why-i-built-a-btc-trading-bot/) if you haven't read it.*

*If you're evaluating agent frameworks for your own automation project, I'd love to hear what you chose and why. Every use case is different.*
