---
title: "How Multi-Agent AI Is Replacing $200/Hour Legal Associates in Document Review"
date: 2026-03-02T15:00:00+09:00
draft: false
description: "Law firms spend 60-80% of litigation budgets on document review. Multi-agent AI systems are cutting that by 90% while improving accuracy. Here's exactly how it works, with implementation prompts."
tags: ["AI agents", "legal tech", "document review", "e-discovery", "multi-agent systems", "LLM", "automation"]
categories: ["Industry Deep Dives"]
series: ["AI Agents by Industry"]
weight: 1
ShowToc: true
TocOpen: true
cover:
  image: "https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=1200"
  alt: "Legal documents and gavel"
  caption: "Photo by Unsplash"
---

## The $10 Billion Document Review Problem

When a company gets sued — or sues someone — the first phase is discovery. Both sides must produce relevant documents. In a typical corporate litigation case, this means reviewing 500,000 to 5 million documents to determine which are relevant, privileged, or responsive.

At major law firms, this work is done by junior associates and contract attorneys billing $150-400/hour. According to the RAND Corporation's analysis of litigation costs ([RAND, 2012](https://www.rand.org/pubs/monographs/MG1208.html)), document review accounts for 60-80% of total discovery costs in large cases.

The math is brutal:

```
Average large case: 2 million documents
Review rate: 40-60 docs/hour (human reviewer)
Hours needed: ~40,000 hours
At $200/hour: $8,000,000
Accuracy: 70-80% (human inconsistency across reviewers)
```

This is the kind of problem multi-agent AI was born to solve: massive scale, repetitive judgment, high cost, and measurable accuracy.

## What Multi-Agent Legal Review Actually Looks Like

A single LLM reading documents one-by-one is already better than nothing. But a *multi-agent system* can replicate the actual workflow of a legal review team — with specialization, quality control, and escalation paths.

Here's the architecture I'd build (and that several legal tech companies are building variants of):

```
┌───────────────────────────────────────────────────┐
│           Multi-Agent Legal Review System           │
│                                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────┐│
│  │  Intake      │  │  Classifier │  │  Privilege  ││
│  │  Agent       │  │  Agents     │  │  Agent      ││
│  │              │  │  (5-10x)    │  │             ││
│  │  OCR, parse, │  │  Relevance  │  │  Attorney-  ││
│  │  de-dupe,    │  │  scoring,   │  │  client     ││
│  │  metadata    │  │  issue      │  │  privilege, ││
│  │  extraction  │  │  coding     │  │  work       ││
│  │              │  │             │  │  product    ││
│  └──────┬──────┘  └──────┬──────┘  └──────┬─────┘│
│         │                │                 │       │
│         v                v                 v       │
│  ┌─────────────────────────────────────────────┐  │
│  │              QC / Audit Agent                │  │
│  │  Random sample 10%, flag disagreements,      │  │
│  │  measure inter-annotator agreement           │  │
│  └──────────────────┬──────────────────────────┘  │
│                     │                              │
│                     v                              │
│  ┌─────────────────────────────────────────────┐  │
│  │           Senior Review Agent                │  │
│  │  Handles escalations, borderline cases,      │  │
│  │  produces review protocol updates            │  │
│  └──────────────────┬──────────────────────────┘  │
│                     │                              │
│                     v                              │
│  ┌─────────────────────────────────────────────┐  │
│  │           Reporting Dashboard                │  │
│  │  Progress, accuracy metrics, cost tracking   │  │
│  └─────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────┘
```

### Why multiple agents, not one?

1. **Specialization** — The intake agent handles OCR and parsing (a different skill than legal reasoning). The privilege agent needs deep understanding of attorney-client privilege doctrine. A single prompt trying to do everything produces worse results than specialized agents.

2. **Parallelism** — 5-10 classifier agents can review documents simultaneously. A 2-million document set that takes 40,000 human-hours can be processed in hours.

3. **Quality control** — The QC agent samples completed work and flags inconsistencies, similar to how a senior associate spot-checks junior reviewers. This catches drift and errors.

4. **Escalation** — Borderline documents get routed to the senior review agent, which has access to the full case context and review protocol. This mirrors how real review teams handle ambiguous documents.

## Real Numbers: Cost and Accuracy

### Cost comparison

| Method | Cost per document | 2M document case |
|--------|------------------|-------------------|
| Human review (associates) | $3.33-$10.00 | $6.6M - $20M |
| Human review (contract attorneys) | $1.50-$4.00 | $3M - $8M |
| TAR 1.0 (keyword + ML) | $0.50-$1.50 | $1M - $3M |
| Multi-agent AI (2025 pricing) | $0.05-$0.20 | $100K - $400K |

The multi-agent cost assumes GPT-4o-level models at current API pricing (~$2.50/1M input tokens). For a 2-page document averaging 1,000 tokens, that's $0.0025 per document for the LLM call alone, plus overhead for multiple agent passes.

### Accuracy

This is where it gets interesting. A 2023 study published in the *Journal of Law and Technology at Texas* ([Grossman & Cormack, 2023](https://doi.org/10.15781/T2MS3K73P)) found that LLM-based review achieved recall rates of 85-95% and precision of 80-90% on standard TREC Legal Track datasets — comparable to or exceeding human reviewer performance.

The key insight: **human reviewers are inconsistent**. Studies consistently show inter-annotator agreement (how often two human reviewers agree on the same document) at only 70-80%. AI reviewers are at least *consistently* wrong in predictable ways that can be identified and corrected.

## Implementation: The Classifier Agent Prompt

Here's a production-grade prompt for the core classification agent. This is the kind of prompt that actually works in practice — it's specific, structured, and includes the review protocol:

```markdown
You are a document review attorney specializing in e-discovery. 
Your role is to classify documents for relevance and issue coding 
in the matter of [CASE NAME].

## Case Summary
[Insert 2-3 paragraph case summary]

## Review Protocol
Relevant documents are those that:
1. Discuss, reference, or relate to [specific subject matter]
2. Were created between [date range]
3. Involve any of the following custodians: [list]
4. Contain information about [specific topics/issues]

A document is NOT relevant if it:
1. Is purely administrative (meeting scheduling, lunch orders) 
   with no substantive discussion
2. Relates to [excluded topics]
3. Is a duplicate of an already-reviewed document

## Issue Codes
Apply all that apply:
- CONTRACT: References the [specific] agreement or its terms
- NEGOTIATION: Discusses negotiation of terms
- BREACH: References potential or actual breach
- DAMAGES: Discusses financial impact or damages
- COMMUNICATIONS: External communications with [counterparty]

## Output Format
For each document, respond with:
{
  "doc_id": "[ID]",
  "relevant": true/false,
  "confidence": 0.0-1.0,
  "issue_codes": ["CODE1", "CODE2"],
  "privilege_flag": true/false,
  "reasoning": "One sentence explaining your classification",
  "escalate": true/false
}

Set escalate=true if:
- Confidence < 0.7
- Document appears to contain privileged material
- Document discusses topics not covered in the review protocol

## Important
- When in doubt, err on the side of marking relevant (over-inclusion 
  is preferred over missing relevant documents)
- Do not skip or summarize — classify every document presented
- Your reasoning must reference specific content from the document
```

### The QC Agent prompt

```markdown
You are a senior review attorney conducting quality control.

You will receive:
1. The original document
2. The classification from the primary reviewer

Your job:
1. Independently classify the document using the same protocol
2. Compare your classification to the primary reviewer's
3. Flag any disagreements

Output:
{
  "doc_id": "[ID]",
  "qc_relevant": true/false,
  "qc_issue_codes": ["..."],
  "agrees_with_primary": true/false,
  "disagreement_type": "relevance|issue_code|privilege|none",
  "qc_notes": "Explanation if disagreement"
}

Only flag genuine disagreements. Minor differences in issue coding 
(e.g., missing a secondary code) should be noted but not flagged 
as disagreements.
```

## Who's Already Doing This

Several companies are building production versions of multi-agent legal review:

- **Harvey AI** (backed by Sequoia, $100M+ raised) — uses LLMs for contract review, due diligence, and litigation support. Their system handles multi-step legal reasoning with specialized models ([Harvey AI](https://www.harvey.ai/)).

- **CoCounsel by Thomson Reuters** — integrated into Westlaw, handles document review, deposition preparation, and contract analysis. Uses a multi-step approach where different AI components handle different tasks ([Thomson Reuters, 2024](https://legal.thomsonreuters.com/en/products/cocounsel)).

- **Relativity aiR** — built into the Relativity e-discovery platform, provides AI-assisted review with confidence scoring and escalation workflows ([Relativity](https://www.relativity.com/air/)).

None of these companies publicly describe their systems as "multi-agent" — the marketing term is "AI-assisted review" or "AI-powered legal research." But under the hood, the architecture involves multiple specialized components working in coordination, which is functionally a multi-agent system.

## The Bigger Picture: What This Means for Law

The implications are significant and already unfolding:

**Short-term (2025-2026):** Document review costs drop 80-90%. Mid-size firms that couldn't afford large-scale discovery can now compete with BigLaw on document-heavy cases. Contract attorney staffing agencies face existential pressure.

**Medium-term (2026-2028):** The multi-agent approach expands beyond document review to contract drafting (multiple agents handling different clauses), regulatory compliance monitoring (agents tracking regulatory changes across jurisdictions), and due diligence (agents reviewing data rooms).

**Long-term (2028+):** The question becomes whether legal judgment itself — not just document classification — can be delegated to agent systems. My bet: routine legal judgment (is this clause standard? does this contract have unusual terms?) yes. Novel legal reasoning (how should this ambiguous statute be interpreted?) no, not for a long time.

## Try It Yourself

If you want to experiment with multi-agent document review on a small scale:

1. Pick any set of 50-100 documents (contracts, emails, reports)
2. Write a clear review protocol (what's relevant, what's not)
3. Use the classifier prompt above with Claude or GPT-4
4. Process documents in batches of 10
5. Run 10% through the QC agent
6. Measure agreement rate between classifier and QC

You'll likely see 85-90% agreement, which is already at or above human inter-reviewer agreement. The entire exercise will cost less than $1 in API fees and take about 30 minutes.

That's the future of legal review. Not a single genius AI lawyer — a team of specialized agents, each doing one thing well, coordinated by a system that ensures quality.

---

*This is the first in a daily series exploring how multi-agent AI is transforming specific industries. Tomorrow: healthcare — how agent teams are accelerating drug discovery pipelines.*

*Sources and references are linked inline. If you spot an error or have additional data, leave a comment.*
