---
title: "I Wrote a 250-Page Book in 6 Days Using AI Agents"
date: 2026-03-06T09:00:00+09:00
description: "How I used OpenClaw, Claude, and a team of six AI sub-agents to write a full-length book about AI automation — and what I learned about the future of creative work."
categories: ["AI Book"]
tags: ["ai-writing", "openclaw", "claude", "ai-agents", "book-writing", "automation", "llm"]
series: ["AI Book"]
series_order: 1
draft: false
cover:
  image: "https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=1200"
  alt: "Open book with pages"
  caption: "Photo by Unsplash"
---

On February 16th, 2026, at 9:45 PM, I sat down and typed a message into a Telegram bot:

> "We're writing a book. 250 pages. Deadline: Sunday midnight. Go."

Six days later, I had a complete manuscript. Eight parts, twenty-one chapters, covering everything from generative AI fundamentals to a BTC trading bot with an AI board of directors to a smart factory automation case study.

This isn't a story about a magic button. It was chaotic, exhausting, and sometimes infuriating. Agents crashed. Compaction ate context. Chapters came back filled with fabricated sales numbers I had to delete. I rewrote sections at 3 AM because the AI nailed the structure but completely missed the voice.

But it worked. And the process changed how I think about writing, delegation, and what it means to be an "author" when your co-writers are language models.

## Why I Decided to Do This

I'd been running AI agents for months before the book project started. Not as experiments — as actual production systems.

[OWUW Beat](https://github.com/openclaw/openclaw), my BTC quantitative trading agent, had been generating daily market reports, running R&D research sub-agents, and even convening a weekly governance board of nine AI members to vote on strategy changes. It was built on [OpenClaw](https://github.com/openclaw/openclaw), an open-source AI agent platform that connects Claude (or other LLMs) to Telegram, giving agents persistent memory, cron jobs, file system access, and tool use.

I also had Marie, a personal assistant agent, and OWUW Stock, a newer agent focused on AI-themed equities. Three agents, running 24/7 on a Mac Mini, talking to me through Telegram.

After a few months of this, I realized I was sitting on something unusual: **81 recorded agent sessions** with full conversation logs, decision trails, code artifacts, and memory files. Every trade decision, every R&D proposal, every board vote — all documented.

The obvious question was: could I turn this into a book?

The less obvious question was: could the agents help write it?

## The Setup That Made It Possible

Let me be specific about the tooling, because "I used AI to write a book" can mean anything from "I pasted chapters into ChatGPT for editing" to "I had fully autonomous agents drafting in parallel." What I did was closer to the latter.

### The Platform: OpenClaw

[OpenClaw](https://github.com/openclaw/openclaw) is a self-hosted AI agent runtime. You install it on a Mac, Linux box, or Raspberry Pi, connect it to an LLM provider (Anthropic, OpenAI, etc.), and wire it up to a messaging channel — Telegram, Discord, Signal, whatever.

What makes it different from just using the Claude API is the agent layer:

- **Persistent memory**: Agents have `MEMORY.md` files and daily memory logs (`memory/YYYY-MM-DD.md`). They remember conversations across sessions.
- **File system access**: Agents can read and write files directly. No copy-pasting.
- **Cron jobs**: You can schedule recurring tasks — daily reports, weekly reviews, automated check-ins.
- **Sub-agent spawning**: An agent can spin up isolated sub-sessions to handle specific tasks, then report back.
- **Tool use**: Web search, browser control, shell commands, image analysis.

This isn't a chatbot. It's closer to a junior employee who lives in your terminal and never sleeps.

### The Model: Claude

The book agent ran on Claude (Anthropic's model, specifically claude-opus-4-6 equivalent at the time). I chose Claude for three reasons:

1. **Long context window**: 200K tokens meant I could feed entire chapters plus style guides plus reference material in a single prompt.
2. **Writing quality**: In my experience across dozens of agent sessions, Claude produces more natural prose than GPT-4 for long-form content. Less of the "furthermore" and "it's important to note" verbal tics.
3. **Instruction following**: The book had a specific style guide (해요체, reader-participatory tone, question-driven transitions) and Claude stuck to it more consistently than alternatives I tested.

### The Agent Architecture

Here's where it gets interesting. I didn't use one agent. I used six teams:

| Team | Role | What They Did |
|------|------|---------------|
| Editorial (편집장) | Project management | Tracked progress, managed timeline, resolved conflicts between chapters |
| Research (리서치) | Source material | Searched the web, analyzed agent logs, gathered statistics and citations |
| Writing (집필) | Parallel drafting | Multiple sub-agents writing different chapters simultaneously |
| Proofreading (교정) | Quality control | Style guide enforcement, fact-checking, consistency passes |
| Smart Factory (스마트팩토리) | Domain expert | Specialized content for the manufacturing automation chapter |
| Structure (구조) | Architecture | Table of contents, chapter flow, cross-references, page balancing |

Each team was an OpenClaw agent session or sub-agent spawn. They could read each other's output files but couldn't modify them — a deliberate isolation choice to prevent one agent from accidentally overwriting another's work.

The writing team was the most parallel. On peak days, I had three sub-agents drafting different chapters simultaneously, each with its own context window loaded with the relevant source material and style guide.

## What the Book Covers

The manuscript landed at eight parts:

1. **The State of Generative AI** (~35 pages) — Where the technology actually stands in 2026, stripped of hype
2. **AI Tools & Setup Guide** (~40 pages) — Practical walkthrough of OpenClaw, API setup, Telegram bots
3. **Case Study: BTC Automated Trading** (~45 pages) — OWUW Beat's full architecture, from regime detection to AI governance
4. **Case Study: Smart Factory** (~45 pages) — AI-driven manufacturing monitoring, quality tracking, predictive maintenance
5. **Case Study: English Learning App** (~35 pages) — Building an AI tutor with speech recognition
6. **AI Governance & Automation Frameworks** (~25 pages) — The R&D → proposal → board vote → auto-apply pipeline
7. **Future Outlook & Getting Started** (~15 pages) — What's coming next and how to begin
8. **AI Team Retrospective** (~10 pages) — What the agents themselves "thought" about the process

The total came to roughly 250 pages at 신국판 (152×224mm) formatting, Batang 10pt.

## The Brutal Realities

Here's what nobody tells you about writing with AI agents. The highlight reel — "250 pages in 6 days!" — obscures how much human work was actually involved.

### Reality 1: Fabrication is the Default

In Part 3, the smart factory chapter, the writing agent produced detailed case studies about overseas sales operations that sounded incredibly compelling. Revenue numbers, client names, regional breakdowns.

None of it was real. The agent invented it wholesale.

I had to delete entire sections and rewrite them with actual data from the factory monitoring system. The lesson: AI agents will confidently fill gaps in their knowledge with plausible fiction. You cannot trust any specific claim without verification, especially numbers.

### Reality 2: Context Window Management is Real Engineering

Each chapter draft was around 10,000-15,000 Korean characters (~15 pages). The style guide was another 2,000 characters. Source material from agent logs could easily hit 50,000+ characters.

When you're pushing against context limits, agents start "forgetting" the style guide or contradicting earlier chapters. I learned to structure prompts with a clear hierarchy:

```
System: You are a book writing agent.
Priority 1: Follow STYLE_GUIDE.md exactly (해요체, reader-participatory tone)
Priority 2: Use ONLY facts from the provided source material
Priority 3: Match the chapter outline structure
Priority 4: Target 15 pages / 21,000 characters

[STYLE_GUIDE.md contents]
[Chapter outline]
[Source material - trimmed to most relevant sections]
```

The ordering mattered. When I put source material before the style guide, the agent would nail the facts but write in a completely different voice.

### Reality 3: Iteration is Everything

No chapter was done in one pass. The actual process looked like this:

1. **Structure pass**: Agent generates a chapter outline with section headers, estimated lengths, key points per section
2. **Draft pass**: Agent writes the full chapter based on the outline
3. **Human review**: I read the draft, mark sections that are wrong, weak, or off-voice
4. **Revision pass**: Agent rewrites marked sections with specific feedback
5. **Style pass**: A separate "proofreading" agent reviews for style guide compliance
6. **Final human read**: I do one last pass for flow and voice

Steps 3-4 often repeated two or three times per chapter. The timeline was tight — 6 days for 250 pages — but I made a deliberate rule: **if you finish early, invest in quality, not quantity.** Re-read. Re-write. Agonize over word choices.

That rule came from experience. When I let agents race ahead to the next chapter without thorough review, the quality of later chapters degraded because they were building on unchecked foundations.

### Reality 4: Voice is the Hardest Thing to Delegate

The book's style guide specified a very particular Korean writing voice — conversational but authoritative, using 해요체 (polite informal ending), with lots of direct reader address ("이 목록을 가만히 보세요 — look at this list carefully") and emotional beats.

Claude could approximate this voice about 70% of the time. The other 30% slipped into either:
- **Textbook mode**: Dry, passive, no personality
- **Overselling mode**: "Amazing!" "Incredible!" — the classic AI enthusiasm nobody asked for

That 30% required human rewriting. And honestly, the human rewriting is what makes it a book instead of a long blog post. Voice isn't just word choice; it's rhythm, pacing, knowing when to speed up through technical details and when to slow down for a story.

## What I'd Do Differently

### Use More Granular Sub-Agents

I started with broad assignments: "Write Chapter 5." This produced mediocre results because the agent tried to hold too much context.

By the end of the project, I was assigning at the section level: "Write section 2.3: the regime detection model. Here's the specific code from OWUW Beat's regime_model.py. Target: 3,000 characters." This worked dramatically better.

If I did it again, I'd break every chapter into 4-5 section-level tasks from the start.

### Build the Fact-Checking Pipeline First

I lost almost a full day to the fabrication problem in Part 3. A pre-built fact-checking step — where a separate agent cross-references every specific claim against source material before human review — would have caught this earlier.

Here's the prompt I eventually developed for fact-checking:

```
Review the following chapter draft against the provided source material.
For every specific claim (numbers, dates, names, technical specifications):
1. Mark it as VERIFIED if it appears in the source material
2. Mark it as UNVERIFIED if it does not
3. Mark it as FABRICATED if it contradicts the source material

Do not suggest improvements. Only verify facts.

[Chapter draft]
[Source material]
```

### Maintain a Running "Canon" Document

By chapter 15, agents were occasionally contradicting things established in chapter 3. A "canon" document — a living reference of established facts, terms, and narrative threads — would have prevented this.

## The Numbers

Some metrics from the project:

- **Total time**: 6 days (Feb 16-22, 2026)
- **Final page count**: ~168 pages at snapshot (52% of 320-page stretch goal), with 21 chapters drafted
- **Strong chapters** (10+ pages, fully reviewed): 8
- **Chapters needing expansion**: 8
- **Agent sessions used**: 81 total across all agents
- **Estimated human hours**: 40-50 (yes, it was basically a full-time week)
- **Estimated agent compute hours**: Hard to measure exactly, but roughly 200+ API calls across all sub-agents

The honest assessment: I got a solid first draft, not a finished book. Several chapters needed expansion from 4-6 pages to 10-15 pages. Part 3 needed a factual rewrite. The novel companion project (a science fiction story about an AI trader, because why not) was only 4 chapters in.

But as a first draft produced in 6 days by one person with AI assistance? I'd never have gotten there alone. Not in 6 days, probably not in 6 months.

## What This Means for Writers

I'm not going to claim AI will replace authors. That's a boring prediction and probably wrong in the way people mean it.

What I will say: the bottleneck in writing has shifted. It used to be **production** — the physical act of generating words. That bottleneck is gone. Claude can produce 10,000 coherent words in minutes.

The new bottlenecks are:

1. **Judgment**: Knowing what to write, what to cut, what's actually interesting
2. **Voice**: The specific way *you* say things that no model can fully replicate
3. **Truth**: Verifying that what the AI wrote is actually accurate
4. **Architecture**: Structuring a 250-page work so it flows and builds

These are all human skills. But they're different human skills than "sit at a keyboard and type for eight hours." The writer's job is evolving from producer to director.

Whether that's exciting or terrifying depends on how you feel about directing.

## What's Next in This Series

This is Part 1 of a 5-part series documenting the AI book-writing experience:

- **Part 1**: Why write a book with AI (you're here)
- **Part 2**: The technical setup — OpenClaw, agents, memory architecture
- **Part 3**: The writing process — prompts, iteration, quality control
- **Part 4**: What went wrong — failures, hallucinations, and rewrites
- **Part 5**: Results and honest assessment — was it worth it?

Next Friday, I'll get into the technical details of how the agent team was structured, including the actual OpenClaw configuration, memory file formats, and the cron schedules that kept everything running.

---

*This post is part of the [AI Book series](/series/ai-book/) documenting my experience writing a full-length book with AI agents. The book itself covers AI automation, quantitative trading, and smart factory systems — all built and operated by one person with AI assistance.*

*Previously in the OWUW series: [Why I Built a BTC Trading Bot with AI Agents](/posts/series/owuw-beat/01-why-i-built-btc-trading-bot-with-ai-agents/) | [Choosing the Tech Stack](/posts/series/owuw-beat/02-choosing-the-stack/)*
