---
title: "AI Is Designing Drugs Now — And the First Ones Are Working"
date: 2026-03-09T06:24:00+09:00
draft: false
description: "AI-designed drugs are entering human trials and showing results. Here's how the pipeline works, who's winning, and what it means for pharma's $2.9B AI bet."
tags: ["AI agents", "drug discovery", "pharma AI", "Insilico Medicine", "AlphaFold", "generative AI", "biotech"]
categories: ["Industry Deep Dives"]
series: ["AI Agents by Industry"]
weight: 4
ShowToc: true
TocOpen: true
cover:
  image: "https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?w=1200"
  alt: "Molecular structure visualization in a laboratory"
  caption: "Photo by Unsplash"
---

## A Drug Designed by AI Just Passed a Human Trial

In mid-2025, Insilico Medicine published results in *Nature Medicine* for rentosertib (ISM001-055) — a drug where both the target and the molecule were discovered using generative AI. The Phase IIa trial showed improved lung function in patients with idiopathic pulmonary fibrosis after just 12 weeks of treatment ([Insilico Medicine, 2025](https://insilico.com/news/tnrecuxsc1-insilico-announces-nature-medicine-publi)).

That sentence deserves a second read. Not "AI helped screen a library." Not "AI suggested modifications to an existing compound." AI identified a novel biological target (TNIK), generated a new molecule to hit it, and that molecule worked in humans.

This is new territory. And it changes the economics of an industry that spends [$2.6 billion and 12 years](https://aspe.hhs.gov/reports/examination-clinical-trial-costs-barriers-drug-development-0) to bring a single drug to market — with a 90% failure rate.

## The Traditional Drug Discovery Pipeline Is Broken

Before we talk about what AI changes, it helps to understand what it's replacing.

Traditional drug discovery follows a brutal funnel:

1. **Target identification** (1-2 years): Find a protein or pathway involved in a disease
2. **Hit discovery** (1-2 years): Screen millions of compounds to find ones that interact with the target
3. **Lead optimization** (1-3 years): Modify the best hits to improve potency, selectivity, and drug-like properties
4. **Preclinical** (1-2 years): Test in animal models for safety and efficacy
5. **Clinical trials** (6-10 years): Phase I (safety), Phase II (efficacy), Phase III (large-scale confirmation)

The median time from target identification to IND (Investigational New Drug) filing is about 4.5 years. The total cost of failure — all the compounds that die along the way — gets folded into the ones that survive. That's why bringing a single drug to approval costs billions.

The failure rate is the real killer. Roughly 90% of drugs that enter Phase I never make it to approval ([Wong et al., 2019](https://academic.oup.com/biostatistics/article/20/2/273/4817524)). Many of those failures happen because the target was wrong, the molecule had off-target effects nobody predicted, or the drug couldn't reach the right tissue at the right concentration.

Each of those failure modes is, at its core, a prediction problem. And prediction problems are exactly where machine learning excels.

## How AI Actually Fits Into Drug Discovery

AI in pharma isn't one thing. It's a stack of different technologies applied at different stages. Here's what's actually working:

### Target Identification: Finding What to Hit

The first question in drug discovery is: what protein, receptor, or pathway should we target? Get this wrong and nothing downstream matters.

Traditional approaches rely on published literature, genetic association studies (GWAS), and known disease biology. The problem is that human biologists can only hold so many relationships in their heads. The interactome — the map of all protein-protein interactions in a human cell — has roughly 600,000 documented interactions ([BioGRID](https://thebiogrid.org/)), and likely many more undiscovered.

AI approaches to target identification include:

- **Knowledge graph mining**: Companies like [BenevolentAI](https://www.benevolent.com/) build massive graphs linking genes, proteins, diseases, pathways, and drugs. Their system famously identified baricitinib as a potential COVID-19 treatment in February 2020 — before most pharma companies had pivoted — by tracing the virus's entry mechanism through the knowledge graph ([The Lancet, 2020](https://www.thelancet.com/journals/laninf/article/PIIS1473-3099(20)30132-8/fulltext)).

- **Causal inference models**: Rather than just finding correlations (Gene X is associated with Disease Y), newer models try to establish directionality. Recursion Pharmaceuticals uses what they call a "biological map" built from petabytes of cellular imaging data — they've imaged cells under millions of genetic and chemical perturbations to build causal models of how biology responds ([Recursion, 2024](https://www.recursion.com/)).

- **Multi-omics integration**: Combining genomics, proteomics, transcriptomics, and metabolomics data to find convergent signals. Insilico Medicine's PandaOmics platform does exactly this, scoring potential targets based on dozens of data streams simultaneously ([Insilico Medicine](https://insilico.com/pandaomics)).

The practical impact: Insilico claims their AI identified TNIK as a fibrosis target and validated it in roughly 18 months — work that would typically take 3-5 years.

### Molecular Design: Generating New Drugs From Scratch

This is where generative AI has made the most dramatic impact. Instead of screening millions of existing compounds to find ones that bind a target, you can now generate novel molecules designed specifically for that target.

The key architectures:

- **Variational autoencoders (VAEs)**: Encode known drug molecules into a continuous mathematical space, then sample new points in that space to generate novel molecules with desired properties.
- **Generative adversarial networks (GANs)**: A generator creates candidate molecules while a discriminator evaluates them, iterating toward molecules that look "drug-like" while hitting the target.
- **Transformer models**: Treat molecular structures (in SMILES notation) as sequences, similar to how GPT treats text. Generate new sequences that represent valid, synthesizable molecules.
- **Diffusion models**: Adapted from image generation (think Stable Diffusion but for 3D molecular structures). These have become increasingly popular since 2024 for generating molecules with specific binding properties.

Insilico Medicine's Chemistry42 platform uses a combination of these approaches. For the rentosertib program, it generated candidate molecules targeting TNIK and optimized them across multiple properties simultaneously — binding affinity, selectivity, ADMET properties (absorption, distribution, metabolism, excretion, toxicity), and synthetic accessibility ([PubMed, 2025](https://pubmed.ncbi.nlm.nih.gov/40461817/)).

The timeline comparison is stark: traditional hit-to-lead optimization takes 1-3 years. Insilico went from target to preclinical candidate in about 18 months total, at roughly one-tenth the typical cost.

### Structure Prediction: AlphaFold Changed Everything

You can't design a drug to fit a protein if you don't know the protein's 3D shape. Before 2020, experimental methods (X-ray crystallography, cryo-EM) were the only reliable way to determine protein structures. These methods are slow, expensive, and don't work for every protein.

DeepMind's [AlphaFold 2](https://www.nature.com/articles/s41586-021-03819-2) solved protein structure prediction in 2020. AlphaFold 3, released in May 2024, extended this to predict interactions between proteins and small molecules, nucleic acids, and other biomolecules ([Isomorphic Labs](https://www.isomorphiclabs.com/our-tech)).

In February 2026, Isomorphic Labs (DeepMind's drug discovery spinoff) unveiled their "Drug Design Engine," which reportedly doubles AlphaFold 3's accuracy in predicting protein-ligand binding ([WinBuzzer, 2026](https://winbuzzer.com/2026/02/11/isomorphic-labs-ai-doubles-alphafold-3-drug-discovery-accuracy-xcxwbn/)). The company has partnerships with Eli Lilly and Novartis worth up to $3 billion combined and expects its first AI-designed molecules to enter Phase I clinical trials by late 2026 ([Reuters, 2026](https://www.reuters.com/business/healthcare-pharmaceuticals/google-backed-ai-drug-discovery-startup-isomorphic-labs-delays-clinical-trial-2026-01-20/)).

This is the infrastructure layer. AlphaFold didn't design any drugs directly, but it made structure-based drug design accessible to every lab on the planet. Before AlphaFold, we had experimental structures for maybe 20% of the human proteome. Now we have predicted structures for essentially all of it.

### ADMET Prediction: Killing Bad Molecules Early

A huge percentage of drug failures happen not because the molecule doesn't hit its target, but because it has problems with absorption, distribution, metabolism, excretion, or toxicity (ADMET). Roughly [40% of clinical failures](https://www.nature.com/articles/nrd4609) are due to safety issues that weren't caught in preclinical testing.

AI models trained on historical ADMET data can predict these properties for novel molecules before any lab work is done. This means you can filter out problematic candidates computationally, saving years of wasted preclinical and clinical work.

Schrödinger, a publicly traded computational chemistry company, has built an extensive ADMET prediction platform that's integrated into several major pharma pipelines. Their approach combines physics-based molecular simulations with machine learning, and they now have their own clinical-stage pipeline with multiple programs ([Schrödinger](https://www.schrodinger.com/drug-discovery/)).

## Who's Actually Winning

The AI drug discovery landscape has consolidated significantly since the hype cycle of 2021-2022. Here's where the major players stand as of early 2026:

### Tier 1: Clinical Validation

**Insilico Medicine** is the current frontrunner by one critical metric: they have the most advanced AI-native drug (where both target and molecule were AI-generated) in clinical development. Rentosertib's positive Phase IIa data, published in *Nature Medicine* with an impact factor of 58.7, is the strongest clinical evidence yet that end-to-end AI drug discovery works.

**Relay Therapeutics** takes a different approach — using AI to understand protein motion (not just static structures) to design precision medicines. Their lead program, RLY-2608, is a mutant-selective PI3Kα inhibitor in Phase I/II for breast cancer. The company generated $15.6 million in collaboration revenue in 2024 and has multiple programs advancing ([Relay Therapeutics](https://relaytx.com/)).

**Schrödinger** straddles the line between software vendor and drug company. Their computational platform is used by most major pharma companies, and they're advancing their own pipeline with clinical candidates in oncology.

### Tier 2: Platform Scale

**Recursion-Exscientia** merged in late 2024 to create the largest AI drug discovery platform by data scale. Recursion's massive cellular imaging dataset combined with Exscientia's automated precision chemistry creates an end-to-end pipeline. They have partnerships with Roche-Genentech, Sanofi, and Bayer, and multiple programs in clinical trials including REC-994 for cerebral cavernous malformation and REC-394 for C. difficile ([Recursion IR, 2025](https://ir.recursion.com/news-releases/news-release-details/recursion-and-exscientia-two-leaders-ai-drug-discovery-space)). Revenue for Q1 2025 was $15 million, largely from partnership milestones ([Fierce Biotech, 2025](https://www.fiercebiotech.com/biotech/several-months-after-exscientia-merge-ai-outfit-recursion-reworks-pipeline)).

**Isomorphic Labs** has the deepest pockets (Google backing) and arguably the best foundational technology (AlphaFold lineage). But they're pre-clinical. The $3 billion in partnership deals with Lilly and Novartis signal confidence, but clinical data is what matters, and that's still at least a year away.

### Tier 3: Emerging

**Atomwise** focuses on structure-based drug design using convolutional neural networks for binding affinity prediction. **Generate Biomedicines** (acquired by Novartis in 2024 for $1 billion) applies generative AI to protein therapeutics rather than small molecules. **BPGbio** is pushing Bayesian causal AI specifically for clinical trial design and patient selection.

## The Market Numbers

The AI drug discovery market is growing fast, though analysts can't seem to agree on exactly how fast:

- Grand View Research estimates the market at **$2.35 billion in 2025**, growing to $2.91 billion in 2026 ([Grand View Research](https://www.grandviewresearch.com/industry-analysis/artificial-intelligence-drug-discovery-market))
- Drug Target Review projects the broader AI drug discovery space at **$5-7 billion in 2025**, reaching $8-10 billion in 2026 ([Drug Target Review, 2026](https://www.drugtargetreview.com/article/192962/ai-in-drug-discovery-predictions-for-2026/))
- McKinsey estimates generative AI could deliver **$60-110 billion annually** in value for pharma overall, including drug discovery, clinical development, and commercial operations

The discrepancy in market sizing comes from what you include. Narrow definitions (just AI software for drug discovery) give you the lower numbers. Broader definitions (including AI-enabled CRO services, computational chemistry, and partnership deal values) push toward the higher end.

What's not disputed: every major pharmaceutical company now has AI drug discovery partnerships or internal programs. Pfizer, Novartis, Roche, Sanofi, AstraZeneca, Merck, Bristol-Myers Squibb — all of them. This stopped being optional around 2023.

## What's Actually Different About AI-Designed Drugs

Here's the question skeptics ask, and it's a good one: if AI just finds molecules that bind to targets, how is that fundamentally different from high-throughput screening? Pharma has been using computational chemistry for decades.

Three things are genuinely new:

### 1. Generative Design vs. Screening

Traditional computational chemistry starts with existing molecules and asks "which of these might work?" Generative AI starts with a target and asks "what molecule should I create?" The search space for drug-like molecules is estimated at 10^60 — far larger than any library you could physically create or computationally screen. Generative models can explore this space efficiently by learning the underlying patterns of drug chemistry.

### 2. Multi-Objective Optimization

Real drug design requires optimizing dozens of properties simultaneously — binding affinity, selectivity, solubility, metabolic stability, lack of toxicity, synthetic accessibility. Improving one often worsens another. Traditional medicinal chemistry handles this through sequential iteration: make a change, test it, see what breaks, try to fix it.

AI models can optimize across all these properties simultaneously, exploring the Pareto frontier of tradeoffs much more efficiently than human chemists iterating one variable at a time. This is where the 10x speedup claims come from.

### 3. Novel Chemical Space

Perhaps most importantly, AI-designed molecules tend to be structurally different from known drugs. They occupy regions of chemical space that human chemists wouldn't typically explore because their intuition is trained on existing drug structures. Rentosertib's chemical scaffold is unlike any existing drug — it came from a region of chemical space that a generative model explored because it had no human biases about what a drug "should" look like.

## The Honest Limitations

This field has suffered from hype, and a balanced view requires acknowledging what AI still can't do:

**Clinical outcomes are still sparse.** Rentosertib's Phase IIa results are promising but small-scale. We don't yet have a fully AI-designed drug that's been approved by the FDA. The closest is probably DSP-1181 (designed by Exscientia for Sumitomo Dainippon), which entered Phase I in 2020 but was eventually discontinued — not because the AI design failed, but because the target biology didn't pan out.

**Biology is still hard.** AI can design molecules with incredible precision, but predicting how those molecules will behave in the complexity of a human body — across different tissues, metabolic states, genetic backgrounds, and disease stages — remains enormously challenging. Most clinical failures are biology failures, not chemistry failures.

**Data quality limits model quality.** AI models are only as good as their training data. Much of the public data on drug-target interactions is noisy, incomplete, or measured under inconsistent conditions. Companies like Recursion have invested hundreds of millions in generating proprietary, standardized datasets precisely because public data isn't good enough.

**Regulatory frameworks are evolving.** The FDA has been receptive to AI-discovered drugs (they're evaluated on the same safety and efficacy criteria as any other drug), but questions about explainability and validation of AI methods in regulatory submissions are still being worked out.

Drug Target Review's forecast for 2026 is blunt: "validation and disappointment in roughly equal measure" ([Drug Target Review, 2026](https://www.drugtargetreview.com/article/192962/ai-in-drug-discovery-predictions-for-2026/)). Some programs will produce positive Phase III data. Others will fail. That's drug development. The question is whether the batting average improves over time.

## What This Means for Builders

If you're a developer or technical founder looking at this space, here's where the opportunities are:

### Data Infrastructure

The biggest bottleneck in AI drug discovery isn't algorithms — it's data. Companies need:
- Standardized assay data pipelines
- Automated lab data capture and annotation
- Integration layers between electronic lab notebooks, LIMS, and ML training pipelines
- Data quality monitoring and drift detection

This is essentially MLOps for biology, and it's badly underserved.

### Specialized Foundation Models

The general-purpose LLM approach (fine-tune GPT on chemistry papers) doesn't work well for drug discovery. The field needs domain-specific models trained on:
- Molecular structures and properties
- Protein sequences and structures
- Biological pathway data
- Clinical trial outcomes

Companies building these specialized models — or the infrastructure to train and deploy them — are well-positioned.

### Clinical Trial Optimization

Even with a perfect molecule, clinical trials remain the bottleneck. AI for trial design, patient recruitment, site selection, and real-time monitoring is a massive market. See our [previous deep dive on AI in clinical trials](/posts/industry/02-ai-agents-clinical-trials/) for specifics.

### Execution Prompts

If you're exploring this space, here are starting points:

```
PROMPT: Target Identification Research Agent

You are a drug target identification specialist. Given a disease
indication, analyze:
1. Known genetic associations (GWAS hits, Mendelian genetics)
2. Expression data (differential expression in disease vs. healthy)
3. Protein-protein interaction networks
4. Existing druggability assessment
5. Competitive landscape (who else is targeting this)

Disease: [INSERT INDICATION]

Output a ranked list of potential targets with:
- Biological rationale
- Strength of genetic evidence
- Druggability score (1-10)
- Competitive risk assessment
- Key papers to review
```

```
PROMPT: Molecular Property Multi-Objective Analysis

Evaluate the following molecular properties for drug candidate
[INSERT SMILES STRING]:

1. Lipinski Rule of Five compliance
2. Predicted solubility (LogS)
3. Predicted membrane permeability (LogP)
4. Predicted metabolic stability (CYP450 interactions)
5. Predicted hERG liability (cardiac toxicity risk)
6. Synthetic accessibility score

Flag any properties outside acceptable ranges and suggest
structural modifications to address them.
```

## The Timeline That Matters

Here's what to watch for through the rest of 2026:

- **Q1-Q2 2026**: Recursion's Phase 2 update on REC-394 for C. difficile. This tests whether their cellular imaging-derived drug design translates to human efficacy.
- **H2 2026**: Isomorphic Labs expects first clinical trials for AlphaFold-designed molecules. If Demis Hassabis's timeline holds, we'll see the first Phase I data from a purely structure-prediction-driven drug design pipeline.
- **Ongoing**: Insilico Medicine will likely advance rentosertib to Phase IIb/III. Positive results here would be the strongest validation yet for end-to-end AI drug discovery.

The pharmaceutical industry moves in decade-long cycles. The AI drug discovery wave started around 2017-2018 with the first major funding rounds. We're now entering the clinical validation phase — the period where the technology either proves itself in human trials or doesn't.

Based on what we've seen so far — particularly rentosertib's Phase IIa results — the early signal is positive. But "early signal" is the operative phrase. Drug development humbles everyone eventually.

## What Comes Next

In our next Industry Deep Dive, we'll examine how AI agents are transforming financial services — from autonomous trading systems to AI-powered compliance monitoring. [Follow the series](/categories/industry-deep-dives/) to catch every post.

---

*This is part of our [AI Agents by Industry](/categories/industry-deep-dives/) series, exploring how autonomous AI systems are reshaping specific sectors with real implementations, not speculation.*
