# Blog Auto-Publishing Configuration

## Schedule (KST)
| Time  | Content Type | Rotation |
|-------|-------------|----------|
| 09:00 | Series post (①②③) | Mon=OWUW Beat, Tue=BlackJyong, Wed=OWUW Beat, Thu=BlackJyong, Fri=AI Book |
| 15:00 | Evergreen post (⑤⑥⑦) | Mon=Industry, Tue=OrgMgmt, Wed=Startup, Thu=Industry, Fri=OrgMgmt, Sat=Startup |
| 22:00 | Daily trading log (④) — FULL company view | Every day |
| Sun 10:00 | Weekly news roundup (⑧) | Weekly |

## Series Tracker
### ① OWUW Beat (10 parts)
- [x] Part 1: Why I built it (published)
- [x] Part 2: Choosing the stack (published 2026-03-04)
- [x] Part 3: First agent — regime detection (published 2026-03-09)
- [x] Part 4: Data collection pipeline (published 2026-03-11)
- [x] Part 5: R&D agent (published 2026-03-16)
- [x] Part 6: AI board of directors (published 2026-03-23)
- [x] Part 7: Dashboard (published 2026-03-25)
- [ ] Part 8: Rebalancing + Earn
- [ ] Part 9: Failures and bugs
- [ ] Part 10: 60-day results

### ② BlackJyong (10 parts)
- [x] Part 1: From BTC to stocks (published 2026-03-10)
- [x] Part 2: 21 Agents, One Portfolio — Tilted Index Architecture (published 2026-03-12)
- [x] Part 3: The AI Benefit Scoring Model (published 2026-03-17)
- [ ] Part 4-10: TBD

### ③ AI Book (5 parts)
- [x] Part 1: Why write a book with AI (published 2026-03-06)
- [x] Part 2: Technical setup — OpenClaw, agents, memory architecture (published 2026-03-13)
- [ ] Part 3: The writing process — prompts, iteration, quality control
- [ ] Part 4: What went wrong — failures, hallucinations, rewrites
- [ ] Part 5: Results and honest assessment

## Evergreen Tracker
### ⑤ Industry Deep Dives
- [x] 01: AI Agents in Legal Discovery (published)
- [x] 02: AI Agents in Clinical Trials (published 2026-03-05)
- [x] 03: AI Agents in Supply Chain & Logistics (published 2026-03-08)
- [x] 04: AI Agents in Drug Discovery (published 2026-03-09)
- [x] 05: AI Agents in Insurance Underwriting (published 2026-03-12)
- [x] 06: AI Agents in Precision Agriculture (published 2026-03-15)
- [x] 07: AI Agents in Energy Grid Management (published 2026-03-16)
- [x] 08: AI Agents in Construction (published 2026-03-22)
- [x] 09: AI Agents in Real Estate (published 2026-03-23)

### ⑥ Org Management
- [x] 01: AI Flattening the Org Chart — Middle Management (published 2026-03-03)
- [x] 02: AI Is Killing the Annual Performance Review (published 2026-03-06)
- [x] 03: AI Is Gutting HR Departments (published 2026-03-10)
- [x] 04: AI Is Killing the Project Manager Role (published 2026-03-13)
- [x] 05: AI Is Killing the SDR (published 2026-03-17)
- [x] 06: AI Is Killing the Corporate L&D Department (published 2026-03-20)
- [x] 07: AI Is Killing the Corporate Legal Department (published 2026-03-24)

### ⑦ Startup Ideas
- [x] 01: Vertical AI Agents — Solo Founder's Best Shot at $1M (published 2026-03-04)
- [x] 02: AI Compliance Is a $23B Market — Here's How to Build In It (published 2026-03-07)
- [x] 03: Voice AI Agents Are a $10B Market — How to Build One (published 2026-03-11)
- [x] 04: The AI CFO Is a $100B Opportunity — How to Build One (published 2026-03-21)
- [x] 05: AI Agent Observability Is the New DevOps — A $10B Startup Opportunity (published 2026-03-25)

## Content Rules
- Language: English
- Length: 3,000-4,000 words (MINIMUM 3,000 — never publish under this)
- All claims need sources (linked inline)
- Include practical prompts in code blocks
- No emoji in headings
- No "In this article..." or "Let's dive in!" 
- Tone: experienced dev sharing real experience
- Every post ends with next-post teaser + series link

## SEO Requirements
- title: 60 chars max, include primary keyword
- description: 155 chars max
- H2/H3 hierarchy with keywords
- Internal links to other posts in series
- Tags: 5-7 relevant tags
- Categories: match series name

## Source Directories (READ ONLY)
- OWUW Beat: /Users/ayintoayin/Desktop/OWUW_Beat/
- OWUW Stock: /Users/ayintoayin/Desktop/OWUW_Stock/
- OWUW Book: /Users/ayintoayin/Desktop/OWUW_Book/
- OpenClaw docs: /opt/homebrew/lib/node_modules/openclaw/docs

## Publishing Flow
1. Cron fires → spawns blog agent
2. Agent reads schedule + tracker → determines today's post
3. Agent reads source material (memory files, code, logs)
4. Agent writes post as markdown with frontmatter
5. Agent runs scripts/publish.sh
6. Cloudflare Pages auto-deploys
7. Agent updates tracker
