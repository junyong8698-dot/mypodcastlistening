# Blog Auto-Publishing Configuration

## Schedule (KST)
| Time  | Content Type | Rotation |
|-------|-------------|----------|
| 09:00 | Series post (①②③) | Mon=OWUW Beat, Tue=BlackJyong, Wed=OWUW Beat, Thu=BlackJyong, Fri=AI Book |
| 15:00 | Evergreen post (⑤⑥⑦) | Mon=Industry, Tue=OrgMgmt, Wed=Startup, Thu=Industry, Fri=OrgMgmt, Sat=Startup |
| 22:00 | Daily trading log (④) | Every day |
| Sun 10:00 | Weekly news roundup (⑧) | Weekly |

## Series Tracker
### ① OWUW Beat (10 parts)
- [x] Part 1: Why I built it (published)
- [ ] Part 2: Choosing the stack
- [ ] Part 3: First agent — regime detection
- [ ] Part 4: Data collection
- [ ] Part 5: R&D agent
- [ ] Part 6: AI board of directors
- [ ] Part 7: Dashboard
- [ ] Part 8: Rebalancing + Earn
- [ ] Part 9: Failures and bugs
- [ ] Part 10: 60-day results

### ② BlackJyong (10 parts)
- [ ] Part 1: From BTC to stocks
- [ ] Part 2-10: TBD

### ③ AI Book (5 parts)
- [ ] Part 1: Why write a book with AI
- [ ] Part 2-5: TBD

## Content Rules
- Language: English
- Length: 2,000-3,000 words
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
