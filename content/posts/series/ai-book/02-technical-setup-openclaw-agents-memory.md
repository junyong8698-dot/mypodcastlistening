---
title: "OpenClaw Technical Setup: Agents, Memory, and Architecture"
date: 2026-03-13T00:00:00+09:00
description: "The complete technical breakdown of how I set up OpenClaw with multiple AI agents, persistent memory, and Telegram integration to write a book."
categories: ["AI Book"]
tags: ["openclaw", "ai-agents", "memory-architecture", "telegram-bot", "claude", "multi-agent", "technical-setup"]
series: ["AI Book"]
series_order: 2
draft: false
cover:
  image: "https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=1200"
  alt: "Server room with blue lighting and network cables"
  caption: "Photo by Unsplash"
---

In [Part 1](/posts/series/ai-book/01-why-write-a-book-with-ai-agents/), I told the story of writing a 250-page book in six days with AI agents. The response I got was predictable: "Cool story, but how does the actual setup work?"

Fair question. The book project didn't start with writing. It started with infrastructure. Before a single word of manuscript existed, I'd spent months building a multi-agent system that could run autonomously, retain memory across conversations, execute scheduled tasks, and communicate through Telegram. The book was a byproduct of that system working well enough that it had documented its own construction.

This post is the technical walkthrough. No hand-waving, no "just plug in an API key" oversimplification. I'll cover the actual architecture, the file layouts, the configuration decisions, and the memory system that makes long-running AI agents viable.

## The Core Problem: AI Agents Forget Everything

Every developer who has worked with LLMs hits the same wall. You have a great conversation with Claude or GPT-4. You work through a complex problem. The model gives you exactly what you need. Then you close the tab, open a new session, and it has no idea who you are.

This is the fundamental limitation of stateless API calls. The model's "memory" is just the context window — a fixed-size buffer that gets wiped between sessions and truncated within them. For a one-off coding question, this is fine. For running a trading operation, managing a portfolio, or writing a book over multiple weeks, it's a dealbreaker.

The industry's answer has been RAG (Retrieval-Augmented Generation) — vector databases, embedding pipelines, semantic search over stored documents. It works, but it's complex to set up, expensive to run, and brittle in practice. Embeddings drift. Retrieval relevance degrades. You end up spending more time tuning the retrieval pipeline than using the agent.

[OpenClaw](https://github.com/openclaw/openclaw) takes a different approach. Memory is plain Markdown files on disk. No vector database required (though one is available as an optional layer). The model reads files at session start, writes notes during conversations, and the file system becomes the persistent brain. Simple, auditable, and version-controllable with Git.

## What OpenClaw Actually Is

OpenClaw is a self-hosted gateway that connects chat applications — Telegram, WhatsApp, Discord, Signal, iMessage — to AI models like Claude. You run a single daemon process on your machine, and it becomes the bridge between your messaging apps and an always-available AI agent.

The key architectural decision is that the Gateway owns everything. It maintains provider connections, manages sessions, handles message routing, and orchestrates agent runs. UI clients (the macOS app, CLI, web dashboard, or your phone's Telegram app) are just thin interfaces that talk to the Gateway over WebSocket.

Here's the component layout:

```
┌─────────────────────────────────────────────┐
│                   Gateway                    │
│  (single daemon on Mac Mini / VPS / Pi)      │
│                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Telegram  │  │ WhatsApp │  │ Discord  │   │
│  │ (grammY)  │  │ (Baileys)│  │          │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       └──────────────┼─────────────┘         │
│                      ▼                       │
│              Session Manager                 │
│              ┌──────────────┐                │
│              │  Agent Loop  │                │
│              │  (Claude/    │                │
│              │   GPT/etc)   │                │
│              └──────┬───────┘                │
│                     ▼                        │
│              File System (Workspace)         │
│              memory/ + MEMORY.md             │
└─────────────────────────────────────────────┘
```

For my setup, the Gateway runs on a Mac Mini sitting on my desk in Seoul. It's been running continuously since late 2025. Three agents share the same Gateway process but operate with fully isolated workspaces, sessions, and credentials.

## Installation and Initial Configuration

Getting OpenClaw running is straightforward if you have Node.js 22+ installed:

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
openclaw onboard --install-daemon
```

The onboard wizard walks through model provider authentication (I use Anthropic's Claude directly), channel setup, and workspace initialization. After onboarding, you have a running Gateway and can immediately chat through the web dashboard at `http://127.0.0.1:18789/`.

But the web dashboard isn't the point. The real power comes from connecting Telegram.

### Telegram Bot Setup

Creating a Telegram bot takes about two minutes. You message [@BotFather](https://t.me/BotFather) on Telegram, run `/newbot`, pick a name, and get a token. Then you add it to your OpenClaw config:

```json5
{
  channels: {
    telegram: {
      enabled: true,
      botToken: "YOUR_TOKEN_HERE",
      dmPolicy: "pairing",
      groups: {
        "*": { requireMention: true }
      }
    }
  }
}
```

The `dmPolicy: "pairing"` setting means the bot won't respond to random strangers. When someone messages it for the first time, OpenClaw holds the message and waits for you to approve the pairing:

```bash
openclaw pairing list telegram
openclaw pairing approve telegram <CODE>
```

After approval, that user's DMs are routed to the agent. This is the security model — no API keys exposed, no public endpoints, just a Telegram bot that only responds to approved users.

The result: you open Telegram on your phone, type a message to your bot, and Claude responds. With full context, persistent memory, file system access, tool use, web search, and whatever other capabilities you've configured. From your pocket.

## The Workspace: Where Memory Lives

Every OpenClaw agent has a workspace directory. This is the agent's home — its working directory for all file operations and the source of all persistent context. The default location is `~/.openclaw/workspace`, but you can point it anywhere.

Here's what the workspace looks like for my book-writing agent:

```
/Users/ayintoayin/Desktop/OWUW_Book/
├── AGENTS.md          # Operating instructions
├── SOUL.md            # Persona and tone
├── USER.md            # Who the user is
├── IDENTITY.md        # Agent's name and vibe
├── TOOLS.md           # Tool usage notes
├── MEMORY.md          # Long-term curated memory
├── memory/
│   ├── 2026-02-19.md  # Daily notes
│   ├── 2026-02-22.md
│   ├── 2026-03-09.md
│   └── ...
├── drafts/            # Book chapter drafts
└── logs/              # Reference materials
```

Each file has a specific role in the system prompt assembly:

**AGENTS.md** is the operating manual. It tells the agent what to do at session start (read memory files), what resources it can access (other agent workspaces, read-only), and safety rules (don't modify other agents' files). This is loaded at the start of every session.

**SOUL.md** defines persona and tone. For the book agent, this means "engaging, practical, storyteller." For my trading agent, it's more analytical and terse. The persona file lets you run dramatically different agents from the same Gateway.

**USER.md** tells the agent who it's talking to. My name, how to address me, my timezone, communication preferences (I send Korean voice messages), and project context. This prevents the agent from asking "Who are you?" every session.

**MEMORY.md** is the long-term memory store. Curated, edited, and treated as the canonical record of important decisions, preferences, and facts. Only loaded in the main private session to avoid leaking personal context into group chats.

**memory/YYYY-MM-DD.md** files are daily logs. Append-only during the day, read at session start (today + yesterday). This is where running context lives — what happened in the last conversation, what tasks are pending, what decisions were made.

### Why Plain Markdown Beats Vector Databases

I want to be specific about why this design works better than the alternatives for my use case.

With a vector database (Pinecone, Weaviate, Chroma), you embed chunks of text, store them, and retrieve semantically similar chunks at query time. The problems:

1. **Embedding quality degrades for domain-specific content.** When my trading agent discusses "regime switching models" or "macro factor exposure," general-purpose embeddings don't reliably surface the right context.

2. **Retrieval is probabilistic.** You never know with certainty what the model will see. A critical decision from three weeks ago might not surface because the embedding similarity score is 0.01 below threshold.

3. **No editability.** Try correcting a wrong memory in a vector store. You have to find the chunk, delete it, re-embed the corrected version, and hope the new embedding lands in the right neighborhood.

4. **Operational overhead.** A vector database is another service to run, monitor, and pay for.

With Markdown files:

1. **You can read exactly what the agent knows.** Open `MEMORY.md` in any text editor and see every piece of long-term context.

2. **Edits are trivial.** Wrong information? Open the file, fix the line, save. The agent picks up the correction on the next session.

3. **Git-trackable.** I version-control my agent workspaces. Every memory change has a commit hash, timestamp, and diff. I can roll back the agent's knowledge to any point in time.

4. **Zero infrastructure.** No database to run. No embeddings to compute. No retrieval pipeline to tune.

The tradeoff is that Markdown memory doesn't scale to millions of documents. But for a personal agent system — even one running multiple agents with months of history — the files stay manageable. My OWUW Beat agent's `MEMORY.md` is about 15KB. The daily memory files average 2-3KB each. The entire memory footprint for three agents over four months fits in a single megabyte.

OpenClaw does offer optional vector search via its `memory-core` plugin for cases where you need semantic retrieval across large memory stores. But the base layer is always files, and for most use cases, files are enough.

## Multi-Agent Architecture

This is where the setup gets interesting. I don't run one agent. I run three, each with a completely isolated brain:

**Marie** — Personal assistant. Handles scheduling, research, communication drafting, and general-purpose tasks. Workspace at `/Users/ayintoayin/Desktop/Marie_Beta/`.

**OWUW Beat** — BTC quantitative trading agent. Runs daily market analysis, regime detection, R&D research sessions, and a weekly governance board with nine AI members voting on strategy changes. Workspace at `/Users/ayintoayin/Desktop/OWUW_Beat/`.

**OWUW Stock** — AI-themed equity trading agent. Focused on Korean and US stocks in the AI supply chain. Newer and still being developed. Workspace at `/Users/ayintoayin/Desktop/OWUW_Stock/`.

Each agent is a fully scoped entity with its own:

- **Workspace** (separate files, persona, memory)
- **State directory** (auth profiles, model registry, per-agent config)
- **Session store** (chat history and routing state)
- **Telegram bot** (separate bot token, separate chat)

The isolation is real. OWUW Beat cannot read Marie's memory. Marie cannot modify OWUW Stock's files. Each agent has its own auth credentials and model configuration. They share a Gateway process for efficiency, but operationally they're independent systems.

Setting up a new agent is one command:

```bash
openclaw agents add owuw_book
```

Then you configure bindings to route inbound Telegram messages to the correct agent based on which bot received the message. Verify with:

```bash
openclaw agents list --bindings
```

The multi-agent architecture was critical for the book project. The book agent (OWUW Book) could *read* the other agents' workspaces — their memory files, decision logs, code artifacts — without having write access. This meant the book agent could pull real conversation logs and trading decisions from OWUW Beat's memory as source material, without any risk of corrupting the trading system's state.

## Session Management and Compaction

Here's a problem that doesn't show up in demos but dominates real-world agent usage: context window limits.

Claude's context window is large (200K tokens for Claude 3.5 Sonnet, even more for Opus), but it's not infinite. A productive agent session accumulates context fast. Tool calls, file reads, web searches, long responses — each one eats tokens. After a few hours of active use, you hit the ceiling.

OpenClaw handles this with **automatic compaction**. When a session approaches its context limit, the Gateway triggers a compaction cycle:

1. A **memory flush** fires first — a silent agent turn that reminds the model to write any important context to `memory/YYYY-MM-DD.md` before the context is trimmed.

2. The session history is then compacted: older messages are summarized, tool call details are condensed, and the working context is reduced to fit within the window.

3. The agent continues with the compacted context plus whatever it wrote to memory files during the flush.

The configuration looks like this:

```json5
{
  agents: {
    defaults: {
      compaction: {
        reserveTokensFloor: 20000,
        memoryFlush: {
          enabled: true,
          softThresholdTokens: 4000,
          systemPrompt: "Session nearing compaction. Store durable memories now.",
          prompt: "Write any lasting notes to memory/YYYY-MM-DD.md; reply NO_REPLY."
        }
      }
    }
  }
}
```

The `memoryFlush` is the key innovation. Without it, compaction just discards old context and the agent loses important details. With it, the agent gets a chance to persist anything it considers durable before the trim happens. The user never sees this turn — it's silent, handled entirely between the Gateway and the model.

During the book project, compaction happened dozens of times. Each chapter draft required multiple rounds of research, outlining, writing, and revision. A single chapter could consume 100K+ tokens of context. Without automatic memory flush, the agent would have lost track of the outline, the style decisions, the source material references — everything that makes a multi-session writing project coherent.

## Cron Jobs: The Autonomous Layer

Memory and sessions give you a persistent agent. Cron jobs give you an autonomous one.

OpenClaw's cron system lets you schedule agent turns — messages that fire on a schedule and trigger the agent to do work without human prompting. This is how OWUW Beat generates daily market reports at 8 AM, runs R&D research sessions every Wednesday, and convenes its governance board every Sunday.

For the book project, cron jobs handled:

- **Daily writing sessions** — the book agent would wake up, check its progress tracker, and draft the next section.
- **Review passes** — scheduled re-reads of completed chapters to check for consistency.
- **Source material updates** — pulling the latest trading logs from OWUW Beat's workspace to keep the book's data sections current.

A cron job definition looks like this:

```json5
{
  name: "daily_writing_session",
  schedule: { kind: "cron", expr: "0 9 * * *", tz: "Asia/Seoul" },
  sessionTarget: "isolated",
  payload: {
    kind: "agentTurn",
    message: "Continue writing the next section of the book. Check MEMORY.md for progress tracker.",
    timeoutSeconds: 600
  }
}
```

The `sessionTarget: "isolated"` is important. It means each cron run gets its own session, separate from my main conversation with the agent. The agent does its work, and when it finishes, the result is announced back to my Telegram chat. I wake up to a completed chapter draft in my messages.

This is fundamentally different from a chatbot. A chatbot waits for you to say something. An agent with cron jobs works while you sleep. The book was largely written between midnight and 6 AM Seoul time, with me reviewing and providing feedback during waking hours.

## The System Prompt Assembly

One detail that matters more than people expect: how the system prompt is constructed.

OpenClaw doesn't use a static system prompt. It assembles one dynamically for every agent run, pulling from multiple sources:

1. **Tooling section** — lists available tools (file read/write, exec, web search, browser control, etc.)
2. **Safety guardrails** — no self-preservation, no power-seeking, comply with stop requests
3. **Skills** — loaded on demand when a task matches a skill description
4. **Workspace section** — working directory path
5. **Bootstrap files** — AGENTS.md, SOUL.md, USER.md, IDENTITY.md injected as "Project Context"
6. **Runtime metadata** — host OS, model name, channel, capabilities
7. **Date/time** — current time in the user's timezone
8. **Memory recall instructions** — when and how to search memory files

The bootstrap file injection is what makes the agent "know" who it is and who it's talking to from the first message. There's no warmup period, no "remind me what we were working on." The agent reads its identity, its user profile, and its operating instructions before processing the first human message.

For sub-agents (spawned for background tasks), OpenClaw uses a minimal prompt mode that strips out skills, memory recall, self-update instructions, and messaging — keeping the context lean for focused tasks.

## Practical Setup Prompt

If you want to replicate this setup, here's the prompt I'd give to configure a new OpenClaw agent for book writing:

```
You are a book-writing agent. Your workspace is at [PATH].

At the start of every session:
1. Read MEMORY.md for long-term context
2. Read memory/[today].md and memory/[yesterday].md for recent context
3. Check drafts/ for current manuscript state

When writing:
- Pull source material from [SOURCE_AGENT_WORKSPACE] (read only)
- Write drafts to drafts/[chapter]-[section].md
- Update MEMORY.md progress tracker after each completed section
- Log daily work to memory/[date].md

Never modify files in other agent workspaces.
Ask before any external actions (publishing, API calls).
```

Save this as `AGENTS.md` in your workspace, and the agent will follow it from the first session.

## What This Architecture Enables

The technical setup I've described here — Gateway, Telegram, Markdown memory, multi-agent isolation, compaction with memory flush, cron jobs — isn't complex individually. Each component is simple. The power comes from the composition.

With this running, I have:

- **Three specialized agents** I can message from my phone at any time
- **Persistent memory** that survives across sessions, compactions, and restarts
- **Autonomous operation** via cron jobs that run daily, weekly, or on custom schedules
- **Full audit trail** in version-controlled Markdown files
- **Cross-agent visibility** where the book agent can reference trading logs and the assistant can check on the trading agent's status

The book project proved this architecture works for creative work, not just operational automation. The same memory system that tracks BTC trading regimes can track chapter outlines and style decisions. The same cron system that triggers market analysis can trigger writing sessions.

In [Part 3](/posts/series/ai-book/), I'll get into the actual writing process — the prompts that worked, the iteration cycles, and the quality control workflow that turned raw AI output into publishable chapters. That's where things got messy, and where the real lessons are.

---

*This is Part 2 of the [AI Book series](/posts/series/ai-book/) — documenting how I wrote a book using AI agents. [Part 1: I Wrote a 250-Page Book in 6 Days Using AI Agents](/posts/series/ai-book/01-why-write-a-book-with-ai-agents/)*
