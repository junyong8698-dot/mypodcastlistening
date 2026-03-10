---
title: "Building the Data Collection Pipeline for a BTC Trading Bot"
date: 2026-03-11T00:00:47+09:00
draft: false
description: "How I built a multi-source data pipeline pulling from FRED, Binance, Yahoo Finance, and on-chain APIs to feed a regime-based BTC trading system."
tags: ["data pipeline", "BTC trading", "API integration", "FRED", "Binance API", "on-chain data", "quantitative trading"]
categories: ["OWUW Beat Series"]
series: ["Building OWUW Beat"]
weight: 4
cover:
  image: "https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=1200"
  alt: "Server room with data cables and blinking lights"
  caption: "Photo by Unsplash"
ShowToc: true
TocOpen: true
---

## You Can't Trade What You Can't Measure

In the [previous post](/series/building-owuw-beat/03-regime-detection-first-agent/), I described the regime detection model that finally beat buy-and-hold for Bitcoin. The model uses six factors — MA50 slope, MA200 crossover, Net Liquidity trend, NFCI, copper-to-gold ratio momentum, and DXY momentum — to classify the market into bull, bear, or neutral regimes.

What I didn't explain is where all that data actually comes from. And honestly, getting the data right was harder than building the model itself.

Most trading bot tutorials gloss over this part. They assume you have a clean DataFrame with OHLCV data and some indicators, and they jump straight to backtesting. In reality, building a reliable data pipeline that survives API rate limits, handles missing data gracefully, caches aggressively, and stays free (or nearly free) is a significant engineering challenge. Especially when you're pulling from seven different sources simultaneously.

This post covers exactly how OWUW Beat collects its data, what each source provides, the caching architecture that keeps API costs at zero, and the specific failure modes I hit along the way.

## The Data Sources: What We Need and Where We Get It

OWUW Beat's regime detection model requires data from four distinct domains: price data, macro economic indicators, market microstructure, and sentiment. Here's the full breakdown.

### 1. Price Data — Yahoo Finance (Free, No API Key)

The foundation of everything is BTC-USD price data. I use [Yahoo Finance](https://finance.yahoo.com/) via the `yfinance` Python library, which is free and requires no API key.

```python
import yfinance as yf

btc = yf.download("BTC-USD", start="2017-01-01", progress=False)
btc = btc[['Close']].copy()
btc.columns = ['BTC']
btc.index = btc.index.tz_localize(None) if btc.index.tz else btc.index
```

But BTC price alone is useless without context. The regime model needs to compare Bitcoin against macro assets, so I also pull:

- **DXY (Dollar Index)**: `DX-Y.NYB` — The single most important inverse correlator to BTC. When the dollar strengthens, risk assets including Bitcoin tend to suffer. DXY momentum is one of our six regime factors.
- **S&P 500**: `^GSPC` — Risk-on proxy. BTC's correlation with equities increased dramatically post-2020 as institutional money entered.
- **Gold**: `GC=F` — The copper-to-gold ratio (Cu/Au) is a regime factor. Gold represents safety; copper represents industrial demand. When Cu/Au is rising, the economy is expanding, which is historically good for BTC.
- **Copper Futures**: `HG=F` — The other half of the Cu/Au ratio.
- **US 10-Year Treasury Yield**: `^TNX` — Not a direct regime factor, but crucial for understanding real rates and liquidity conditions.

All of these come from Yahoo Finance. Zero cost. The downside? Yahoo Finance occasionally has data gaps, especially on weekends and holidays where the index data doesn't align with 24/7 crypto trading. The solution is forward-filling:

```python
import pandas as pd

# Merge all on date index
df = pd.concat([btc, dxy, sp500, gold, copper, tnx], axis=1)
df = df.ffill()  # Forward-fill gaps from non-24/7 markets
df = df.dropna()  # Drop any remaining NaN rows at the start
```

Forward-filling is imperfect — it means that on a Saturday, the DXY value is Friday's close. For a system that rebalances every 10 days, this is acceptable. For a high-frequency system, it would be a serious problem.

### 2. Macro Economic Data — FRED API (Free, Key Required)

The Federal Reserve Economic Data ([FRED](https://fred.stlouisfed.org/)) API is one of the most valuable free data sources in finance. You need an API key, which takes about 30 seconds to get at [fred.stlouisfed.org/docs/api/api_key.html](https://fred.stlouisfed.org/docs/api/api_key.html).

OWUW Beat pulls three critical series from FRED:

**Net Liquidity Proxy**: This is the core macro signal. Net Liquidity = Federal Reserve Total Assets minus the Treasury General Account (TGA) minus the Reverse Repo Facility (RRP). When net liquidity is expanding, asset prices tend to rise. When it's contracting, they fall.

```python
import requests

FRED_API_KEY = "your_key_here"

def get_fred_series(series_id, start="2017-01-01"):
    url = f"https://api.stlouisfed.org/fred/series/observations"
    params = {
        "series_id": series_id,
        "api_key": FRED_API_KEY,
        "file_type": "json",
        "observation_start": start,
    }
    r = requests.get(url, params=params, timeout=15)
    data = r.json()["observations"]
    return [(d["date"], float(d["value"])) for d in data if d["value"] != "."]

# Federal Reserve Total Assets
fed_assets = get_fred_series("WALCL")      # Weekly, Wednesday
# Treasury General Account
tga = get_fred_series("WTREGEN")           # Weekly, Wednesday
# Reverse Repo
rrp = get_fred_series("RRPONTSYD")         # Daily

# Net Liquidity = Fed Assets - TGA - RRP
```

The tricky part: these three series update at different frequencies. WALCL and WTREGEN are weekly (Wednesday), while RRPONTSYD is daily. Aligning them requires resampling the weekly data to daily (forward-fill) before computing the net liquidity figure.

**NFCI (National Financial Conditions Index)**: Published weekly by the Chicago Fed. Negative values mean financial conditions are loose (good for risk assets); positive values mean conditions are tight. This is one of the six regime factors.

```python
nfci = get_fred_series("NFCI")  # Weekly, updated Wednesdays
```

**Why FRED matters**: Professional quant funds pay tens of thousands of dollars per year for Bloomberg or Refinitiv terminals to access exactly this data. FRED gives you the same macro indicators for free, just with a slight delay (typically T+1 for daily series, T+3 for weekly). For a system that rebalances every 10 days, this delay is irrelevant.

### 3. Market Microstructure — Binance API (Free, No Key for Public Endpoints)

The [Binance API](https://binance-docs.github.io/apidocs/) provides real-time and historical market microstructure data that you can't get anywhere else for free. OWUW Beat uses the public endpoints (no API key needed for data collection; the key is only needed for order execution).

Here's what we pull:

**Funding Rate**: The perpetual futures funding rate tells you the balance between longs and shorts. Consistently positive funding means longs are paying shorts (bullish market consensus). Negative funding means shorts are paying longs (bearish). When funding goes deeply negative during a bear market, it often signals capitulation — a potential bottom.

```python
def get_funding_rate():
    url = "https://fapi.binance.com/fapi/v1/fundingRate"
    params = {"symbol": "BTCUSDT", "limit": 100}
    r = requests.get(url, params=params, timeout=15)
    data = r.json()
    rates = [float(d["fundingRate"]) for d in data]
    return {
        "current": rates[-1],
        "avg_7d": sum(rates[-21:]) / 21,  # 3 per day × 7 days
        "avg_30d": sum(rates) / len(rates),
    }
```

**Open Interest**: Total value of outstanding futures contracts. Rising OI with rising price = new money entering longs (bullish). Rising OI with falling price = new shorts opening (bearish). Declining OI = positions closing (reduced conviction either way).

```python
def get_open_interest():
    url = "https://fapi.binance.com/fapi/v1/openInterest"
    params = {"symbol": "BTCUSDT"}
    r = requests.get(url, params=params, timeout=15)
    return float(r.json()["openInterest"])
```

**Long/Short Ratio**: The ratio of accounts with net long vs. net short positions. A ratio above 2.0 during a downtrend is a warning sign — retail is stubbornly long while the market is falling.

```python
def get_long_short_ratio():
    url = "https://fapi.binance.com/futures/data/globalLongShortAccountRatio"
    params = {"symbol": "BTCUSDT", "period": "1h", "limit": 24}
    r = requests.get(url, params=params, timeout=15)
    data = r.json()
    return float(data[-1]["longShortRatio"])
```

**Taker Buy/Sell Ratio**: Whether market orders are predominantly buys or sells. This captures aggressive directional flow rather than passive limit orders.

### 4. Sentiment Data — Fear & Greed Index (Free, No Key)

The [Crypto Fear & Greed Index](https://alternative.me/crypto/fear-and-greed-index/) is a composite sentiment indicator that ranges from 0 (Extreme Fear) to 100 (Extreme Greed). It aggregates volatility, market momentum, social media, surveys, dominance, and Google Trends.

```python
def get_fear_greed():
    url = "https://api.alternative.me/fng/?limit=30&format=json"
    r = requests.get(url, timeout=15)
    data = r.json()["data"]
    return {
        "current": int(data[0]["value"]),
        "classification": data[0]["value_classification"],
        "avg_7d": sum(int(d["value"]) for d in data[:7]) / 7,
        "avg_30d": sum(int(d["value"]) for d in data) / len(data),
    }
```

During OWUW Beat's operation, BTC spent over 30 consecutive days in "Extreme Fear" (FNG below 25) during February-March 2026. The regime model correctly identified this as a bear regime and kept allocation at 0%. Without the Fear & Greed data as a confirmation signal, I'd have been second-guessing the model every day, watching BTC hover around $65,000-$69,000 and wondering if I should buy the dip.

### 5. On-Chain Data — Blockchain.info and CoinMetrics (Free)

On-chain data provides information about what's happening on the Bitcoin network itself, independent of exchange activity.

```python
def collect_blockchain_info():
    """Blockchain.com API: hashrate, difficulty, mempool, transactions"""
    stats = requests.get("https://api.blockchain.info/stats", timeout=15).json()
    return {
        "hashrate_thps": stats.get("hash_rate", 0),
        "difficulty": stats.get("difficulty", 0),
        "n_tx_24h": stats.get("n_tx", 0),
        "minutes_between_blocks": stats.get("minutes_between_blocks", 0),
        "market_price_usd": stats.get("market_price_usd", 0),
    }
```

[CoinMetrics](https://coinmetrics.io/) provides the NVT Ratio (Network Value to Transactions) via their community API — think of it as a P/E ratio for Bitcoin. High NVT means the network value is outpacing transaction volume (potentially overvalued); low NVT suggests undervaluation.

```python
def collect_coinmetrics():
    url = ("https://community-api.coinmetrics.io/v4/timeseries/asset-metrics"
           "?assets=btc&metrics=NVTAdj,SplyAct1d,RevUSD&frequency=1d&page_size=30")
    r = requests.get(url, timeout=15)
    return r.json()
```

I should be honest: on-chain data is not currently one of the six regime factors. I collect it, the R&D agent experiments with it, but it hasn't passed the validation criteria for inclusion in the production model. The NVT signal, for example, showed promise in early backtests but failed the bootstrap confidence interval test — the 95% CI for Sharpe ratio improvement overlapped with zero.

I keep collecting it because the R&D agent runs experiments every hour during market hours, and having the data available means it can test new hypotheses without waiting for collection jobs to finish.

## The Caching Architecture

Every API call is wrapped in a caching layer. This isn't optional — it's essential for three reasons:

1. **Rate limits**: FRED allows 120 requests per minute. Binance has weight-based limits. Without caching, a debugging session where you restart the bot 10 times would burn through your quota.

2. **Reliability**: APIs go down. Yahoo Finance has periodic outages. The Fear & Greed API sometimes returns 500 errors. With caching, your most recent data survives outages.

3. **Speed**: The daily market report cron job needs to compute signals from all data sources. If every call hits the network, that's 15+ HTTP requests taking 10-30 seconds total. With caching, it's 15 file reads taking milliseconds.

The implementation is straightforward file-based caching:

```python
import json, time
from pathlib import Path

CACHE_DIR = Path(__file__).parent / "data_cache"
CACHE_DIR.mkdir(exist_ok=True)
CACHE_TTL = 1800  # 30 minutes

def cached_get(url, key, headers=None, ttl=CACHE_TTL):
    cache_file = CACHE_DIR / f"{key}.json"
    if cache_file.exists():
        age = time.time() - cache_file.stat().st_mtime
        if age < ttl:
            with open(cache_file) as f:
                return json.load(f)
    try:
        r = requests.get(url, headers=headers or {}, timeout=15)
        r.raise_for_status()
        data = r.json()
        with open(cache_file, "w") as f:
            json.dump(data, f)
        return data
    except Exception as e:
        # Stale cache is better than no data
        if cache_file.exists():
            with open(cache_file) as f:
                return json.load(f)
        return {"error": str(e)}
```

The key design decision: **stale cache is always returned on API failure**. If Binance's funding rate endpoint returns a 500 error, we use the last cached value (up to 30 minutes old). For a system that rebalances every 10 days, a 30-minute-old funding rate is perfectly acceptable. For a high-frequency system, you'd want a different strategy.

One failure mode I hit: the `data_cache/` directory accumulated hundreds of JSON files over weeks. On macOS, the dashboard's Flask server would occasionally hit "Too many open files" errors because each API endpoint was opening cache files without properly closing file handles. The fix was adding explicit `with open()` context managers everywhere and periodically purging old cache files.

## The Daily Collection Flow

Here's how data collection actually works in production. Every morning at 07:00 KST, a cron job fires the Daily Market Report agent. That agent:

1. Calls `get_fear_greed()` → current FNG value + 7-day and 30-day averages
2. Calls `get_funding_rate()` → current + average funding rates
3. Calls `get_open_interest()` → total BTC futures OI on Binance
4. Calls `get_long_short_ratio()` → retail positioning
5. Pulls BTC price + moving averages from Yahoo Finance
6. Pulls FRED data (Net Liquidity components, NFCI)
7. Computes the macro signal score (a weighted composite of all factors)
8. Determines the current regime (bull/bear/neutral)
9. Generates a recommended allocation percentage
10. Saves everything to `research/daily_market/YYYY-MM-DD.json`
11. Formats a human-readable report and sends it via Telegram

The entire flow takes about 8-12 seconds, with most of that being network latency on the API calls. With warm caches, it drops to under a second.

Here's what a daily market report looks like in the JSON output:

```json
{
  "date": "2026-03-10",
  "btc_price": 66542.30,
  "btc_change_24h": -1.2,
  "rsi_14": 37.3,
  "ma50": 72150.0,
  "ma200": 68900.0,
  "macro_score": 7,
  "regime": "BEAR",
  "fng": {"value": 14, "classification": "Extreme Fear"},
  "funding_rate": {"current": -0.0012, "avg_7d": -0.0008},
  "recommended_allocation_pct": 0,
  "vol_annualized": 0.96
}
```

## What I Learned About API Data Quality

After three weeks of running this pipeline daily, here are the data quality issues I encountered:

**Yahoo Finance weekend gaps**: BTC trades 24/7 but traditional assets don't. On weekends, DXY, S&P 500, gold, and copper have no new data. Forward-filling works, but it means your signals are stale for 2 days out of every 7. For regime detection on 50-day and 200-day moving averages, this barely matters. For shorter-term signals, it's a real problem.

**FRED publication delays**: WALCL (Fed balance sheet) updates on Thursdays for the previous Wednesday. NFCI updates on Wednesdays. This means your net liquidity calculation is always 1-8 days stale. Again, for a 10-day rebalancing cycle, this is fine. The macro trend doesn't change in a week.

**Binance rate limiting**: The public API has a weight-based rate limit system. Most endpoints cost 1-5 weight, with a limit of 1200 weight per minute. I've never hit this with normal operation, but during development when running backtests that pulled historical funding rates in a loop, I got temporarily banned. The fix was adding a simple sleep between requests.

**Fear & Greed API reliability**: The alternative.me API goes down roughly once a week for maintenance, usually for 15-30 minutes. The caching layer handles this transparently, but I discovered the outage pattern only because I logged cache miss rates.

**Blockchain.info throttling**: If you make more than about 10 requests per minute to blockchain.info without an API key, you start getting 429 responses. The cache TTL of 30 minutes keeps us well under this limit.

## The Prompt That Built the Pipeline

I didn't write most of this code by hand. The AI agent (running on [OpenClaw](https://openclaw.ai)) built the data collection pipeline iteratively across the first day of development. Here's the kind of prompt that produced the initial version:

```
Build a data collection module for a BTC quantitative trading system.

Requirements:
1. Collect from these free sources (no paid APIs):
   - Yahoo Finance: BTC-USD, DXY, S&P 500, Gold, Copper, US 10Y yield
   - FRED API: Fed balance sheet (WALCL), TGA (WTREGEN), Reverse Repo (RRPONTSYD), NFCI
   - Binance public API: funding rate, open interest, long/short ratio, taker buy/sell ratio
   - alternative.me: Fear & Greed Index
   - blockchain.info: hashrate, difficulty, mempool, transaction count

2. Every API call must go through a file-based cache with 30min TTL
3. On API failure, return stale cached data (never raise an exception)
4. Each collector function returns a dict with 'source' and 'collected_at' fields
5. All HTTP requests have 15-second timeout
6. Save cache files to data_cache/ subdirectory

Write this as a single Python module: data_collectors.py
```

The agent produced a working version in one pass. Over the next few days, I iterated on it — adding the CoinMetrics collector, fixing timezone handling in Yahoo Finance data, adding the sentiment word lists for Reddit analysis (which the R&D agent later used for experimental features).

The key lesson: **be extremely specific about error handling in your prompt**. The first version the agent produced would crash on API failures. Adding "On API failure, return stale cached data (never raise an exception)" to the prompt fixed it permanently.

## Cost Breakdown

One of the design constraints for OWUW Beat was keeping data costs at zero. Here's the actual cost of running this pipeline for 30 days:

| Source | Cost | Rate Limit | Usage |
|--------|------|------------|-------|
| Yahoo Finance | $0 | Unofficial, ~2000/hr | ~50 calls/day |
| FRED API | $0 | 120/min | ~10 calls/day |
| Binance Public | $0 | 1200 weight/min | ~30 calls/day |
| Fear & Greed | $0 | None published | ~5 calls/day |
| Blockchain.info | $0 | ~10/min | ~5 calls/day |
| CoinMetrics Community | $0 | 100/10min | ~5 calls/day |
| **Total** | **$0** | | **~105 calls/day** |

For comparison, a Bloomberg Terminal costs $24,000/year. A Refinitiv Eikon license is $22,000/year. A Glassnode Professional plan is $800/month. CryptoQuant Advanced is $100/month.

We identified that adding Glassnode + CryptoQuant ($128/month combined) would give us roughly 95% of the institutional-grade on-chain data. That's a potential future upgrade, but the free stack has been sufficient for the regime detection model's needs.

## The R&D Agent's Relationship With Data

The data pipeline doesn't just serve the production trading model. It's the foundation for the R&D agent, which runs every hour during market hours (08:00-18:00 KST, weekdays) and conducts systematic experiments.

The R&D agent has access to all collected data through the same `data_collectors.py` module. When it runs an experiment — say, testing whether adding a Hurst exponent overlay improves regime detection — it calls the same functions the production model uses. This means experiments run on exactly the same data quality and latency characteristics as production, avoiding the classic quant trap of backtesting on clean data and then deploying to noisy live feeds.

After three weeks, the R&D agent had run over 60 experiments across topics like:

- Hidden Markov Model regime detection (rejected: Sharpe 0.32 vs production 1.31)
- Hurst Exponent overlay (promising: Sharpe 1.87, pending full validation)
- Adaptive rebalancing frequency (interesting: 3-day rebal improved Sharpe to 1.42 vs 10-day 1.01)
- Bollinger Band squeeze as regime confirmation (marginal improvement, not statistically significant)
- Volume-managed momentum (rejected: no improvement over price-only momentum)

Every one of these experiments depended on having clean, cached, reliably-updating data. The pipeline isn't glamorous, but it's the foundation that makes everything else possible.

## What I'd Do Differently

If I were starting over, three things would change:

**Use a proper time-series database instead of JSON files.** The file-based cache works, but querying historical data requires loading entire JSON files into memory. Something like [TimescaleDB](https://www.timescale.com/) (free, open source) would let the R&D agent run SQL queries against historical data directly, which would make backtesting significantly faster.

**Add data quality monitoring from day one.** I discovered the Yahoo Finance weekend gap issue, the FRED publication delay, and the blockchain.info throttling through production incidents rather than proactive monitoring. A simple daily check that validates data freshness and completeness would have caught all of these.

**Separate collection from computation.** Currently, the daily market report job collects data and computes signals in the same step. If the collection fails halfway through, the computation runs on a mix of fresh and cached data. A cleaner architecture would be: collection job runs first and writes to a staging area; computation job reads from staging and verifies all data is fresh before proceeding.

## Next in the Series

In [Part 5](/series/building-owuw-beat/05-rd-agent/), I'll cover the R&D agent in detail — how it generates experiment hypotheses, runs them autonomously, evaluates results against the production model's benchmarks, and produces weekly proposals for the AI board of directors. The R&D agent is where the system stops being a static trading bot and starts being a self-improving research platform.

---

*This is Part 4 of the [Building OWUW Beat](/series/building-owuw-beat/) series, documenting how I built an AI-powered BTC trading system using OpenClaw and autonomous agents. [Start from Part 1](/series/building-owuw-beat/01-why-i-built-a-btc-trading-bot/) if you're new here.*
