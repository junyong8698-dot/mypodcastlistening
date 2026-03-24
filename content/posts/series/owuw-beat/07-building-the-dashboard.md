---
title: "Building a Real-Time Trading Dashboard with Flask, React, and Electron"
date: 2026-03-25T00:00:05+09:00
draft: false
description: "How I built a desktop trading dashboard from a 1400-line HTML file to a React + Electron app with live regime data, portfolio tracking, and crash defense monitoring."
tags: ["trading dashboard", "React", "Electron", "Flask API", "BTC trading", "OpenClaw", "data visualization"]
categories: ["OWUW Beat Series"]
series: ["Building OWUW Beat"]
weight: 7
cover:
  image: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=1200"
  alt: "Data analytics dashboard on a monitor screen"
  caption: "Photo by Unsplash"
ShowToc: true
TocOpen: true
---

## Why a Dashboard Matters More Than You Think

In the [previous post](/posts/series/owuw-beat/06-ai-board-of-directors/), I described the governance system — a 9-member AI board that debates and votes on model changes every Sunday. By this point, OWUW Beat had a working regime detection model, an R&D agent generating experiments, and a governance layer deciding which changes ship. The system was functional.

But I couldn't *see* it.

Every time I wanted to check the current regime, I'd ask the Telegram bot. Want to know my portfolio allocation? Telegram. Crash defense status? Telegram. Macro signal? Telegram. Each question required a separate message, a separate response, a separate mental context switch.

This is the problem nobody warns you about when building autonomous trading systems: **the information density problem**. You end up with an agent that knows everything about your portfolio, but the only interface is a chat window that shows one answer at a time.

I needed a dashboard. Not a Grafana instance with generic charts. Not a Jupyter notebook I'd forget to run. A purpose-built, always-on display that showed me the complete state of the trading system at a glance.

This is the story of building it — twice.

## Version 1: The 1,400-Line Monolith

The first dashboard was born out of desperation. I told the OWUW Beat agent to build a web dashboard, and it did what any agent would do with an open-ended request: it crammed everything into a single HTML file.

The result was `dashboard/static/index.html` — 1,400 lines of HTML, CSS, and JavaScript, served by a Flask backend. It had seven tabs:

1. **Dashboard** — regime, price, allocation
2. **Investment Memo** — the formal IM document
3. **R&D Research** — experiment results
4. **Market Report** — daily analysis
5. **Performance** — portfolio tracking
6. **Timeline** — event history
7. **Blog** — English report generation

The Flask backend (`dashboard/app.py`) served both the static files and a set of API endpoints:

```python
# Core API endpoints in app.py
@app.route('/api/signal')      # Regime, macro score, allocation
@app.route('/api/performance_live')  # TWR-based performance tracking
@app.route('/api/research')    # R&D experiment results
@app.route('/api/daily_reports')  # Daily market reports
@app.route('/api/im')          # Investment memo (markdown)
@app.route('/api/model_profile')  # Model parameters
@app.route('/api/blog_reports')   # English blog reports
@app.route('/api/timeline')    # Timeline events
```

For external access, I ran [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-tunnel/) (`cloudflared`) to expose the local Flask server:

```bash
cloudflared tunnel --url http://localhost:5555
```

This gave me a public URL I could access from my phone. The dashboard was accessible. It worked.

And it was terrible.

### What Went Wrong

**Dark theme was the only option.** I wanted to screenshot charts for reports and print them. Dark backgrounds with colored charts look awful on paper. The CEO (me) explicitly wanted a light theme option. The single HTML file had colors hardcoded everywhere.

**Mobile was broken.** Tables overflowed. Charts didn't resize. The seven-tab navigation was unusable on a phone screen. Given that I check the dashboard from my phone 80% of the time, this was a serious problem.

**Loading was slow.** All seven tabs loaded simultaneously, even though you only look at one at a time. Every Chart.js instance initialized on page load. The market report tab alone pulled down megabytes of daily report data.

**No real-time updates.** The dashboard polled the API on a timer, but if you left it open for hours, the data got stale. There was no WebSocket connection, no push updates, no visual indicator of data freshness.

**The authentication was inline.** The login page was literally an HTML string hardcoded inside `app.py`. Password hashing used `werkzeug.security`, which was fine, but the whole thing felt held together with tape.

**One file meant zero maintainability.** Want to change the chart colors on the performance tab? Good luck finding which of the 1,400 lines controls that, without breaking the regime factors display three hundred lines away.

## The V2 Rewrite: React + Electron

After two weeks of squinting at the monolith, I decided to rewrite. Not refactor — rewrite. The agent and I agreed on a plan:

**Stack:**
- [Electron](https://www.electronjs.org/) v28+ for desktop wrapping
- [React 18](https://react.dev/) + [Vite](https://vitejs.dev/) for the frontend
- [Tailwind CSS 3](https://tailwindcss.com/) for styling
- [Recharts](https://recharts.org/) for interactive charts
- Flask backend (kept and refactored)
- [flask-socketio](https://flask-socketio.readthedocs.io/) for WebSocket real-time updates

**Why Electron instead of just a better web app?** Three reasons:

1. **Always-on display.** I wanted the dashboard running on a dedicated screen on my desk. A desktop app stays open. A browser tab gets closed, refreshed, or lost among fifty other tabs.

2. **System tray integration.** The app sits in the macOS menu bar. Red icon means crash defense is active. Green means normal. I see the regime status without even looking at the dashboard.

3. **Local-first.** The Flask API runs on the same machine. Electron connects to `localhost:5555`. No internet required, no Cloudflare tunnel needed for the primary use case.

### Task Force Structure

The agent organized the rewrite into three parallel work streams — it called them "Task Forces," which I found both amusing and effective:

- **TF-1 (UX/Design):** Screen layouts, color system, component hierarchy
- **TF-2 (Frontend):** React components, state management, API hooks
- **TF-3 (Backend):** Flask API refactoring, data migration, Electron packaging

The sprint plan was aggressive: 15 sprints across a single day, from 07:15 to 20:00 KST, with 20-minute intervals. The agent ran through them methodically, tracking progress in a `PROGRESS.md` file.

## Anatomy of the Dashboard

The final V2 dashboard has 10 pages, each as a separate React component in `src/pages/`. Let me walk through the main one.

### The Main Dashboard Page

This is what I look at most. It's a single-screen overview of the entire trading system state.

**Row 1: Core KPIs** — six cards across the top:

| Card | Data Source | Refresh |
|------|------------|---------|
| BTC Price + 24h/3d change | `/api/signal` | 30s |
| Regime (BULL/BEAR/NEUTRAL) | `/api/signal` | 30s |
| Recommended Allocation % | `/api/signal` | 30s |
| Total Assets (Spot + Earn) | `/api/account` + `/api/earn` | 60s |
| Model Return + Sharpe + MDD | `/api/backtest_perf` | 10min |
| Fear & Greed Index gauge | `/api/fng` | 5min |

**Row 2: Three panels** — the detailed view:

**Regime Factors Panel.** Shows all six factors that determine the regime score:

```
MA50 Slope        🟢 +1    (50-day moving average direction)
MA200 Cross       🟢 +1    (price vs 200-day MA)
Net Liquidity     🔴 -1    (US Fed balance sheet - TGA - RRP)
NFCI              🟢 +1    (Financial conditions index)
Cu/Au Ratio       ⚪  0    (Copper/Gold ratio, leading indicator)
DXY Momentum      🟢 +1    (Dollar strength)
```

Each factor is +1, 0, or -1. Sum them up, and you get the regime score (range: -6 to +6). Score > 2 = BULL. Score < -2 = BEAR. Everything else = NEUTRAL.

This panel was critical for debugging. When the regime changed unexpectedly, I could immediately see which factor flipped. Before the dashboard, I'd have to ask the bot, wait for a response, parse the text, and mentally reconstruct the state.

**Crash Defense Panel.** Shows the V5.3 defense system status:

- Crash Defense: Active/Normal (the -5% in 3 days trigger)
- Recovery Step: 0/2 (two-stage recovery after crash)
- RSI (14d): current momentum
- Volatility (20d): for bear vol-targeting
- MA50/MA200: the actual values
- Model Version: confirms we're running V5.3

**Macro Signal Panel.** A visual bar showing the composite macro score (-85 to +85), plus portfolio composition (BTC vs USDT split), and Binance Earn APR with estimated daily yield.

### The Custom Hook That Powers Everything

Every data panel uses a custom React hook called `useApi`:

```javascript
// src/hooks/useApi.js
import { useState, useEffect, useRef } from 'react';

export function useApi(fetchFn, intervalMs = 30000) {
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(true);
  const mountedRef = useRef(true);

  useEffect(() => {
    mountedRef.current = true;
    let timer;

    const load = async () => {
      try {
        const result = await fetchFn();
        if (mountedRef.current) {
          setData(result);
          setError(null);
        }
      } catch (e) {
        if (mountedRef.current) setError(e);
      } finally {
        if (mountedRef.current) setLoading(false);
      }
    };

    load();
    timer = setInterval(load, intervalMs);

    return () => {
      mountedRef.current = false;
      clearInterval(timer);
    };
  }, [fetchFn, intervalMs]);

  return { data, error, loading };
}
```

Simple polling with configurable intervals. The signal endpoint (regime, allocation) refreshes every 30 seconds. Performance data every 60 seconds. Backtest results every 10 minutes. News every 5 minutes.

I considered WebSocket for everything but decided against it. The Flask backend calculates most values on-demand from files on disk (research results, daily reports). Push notifications would require the backend to watch file changes and emit events. Polling at sensible intervals is simpler and good enough.

### The Fear & Greed Gauge

One of the more satisfying components to build was the Fear & Greed Index gauge. It's a half-circle SVG with a needle:

```jsx
function FngGauge({ value, label }) {
  const v = Number(value) || 0;
  const angle = -90 + (v / 100) * 180;
  const color = v <= 25 ? '#ef4444'   // Extreme Fear - red
              : v <= 45 ? '#f97316'   // Fear - orange
              : v <= 55 ? '#eab308'   // Neutral - yellow
              : v <= 75 ? '#84cc16'   // Greed - lime
              : '#22c55e';            // Extreme Greed - green

  return (
    <svg viewBox="0 0 120 70">
      {/* Background arc */}
      <path d="M10 65 A50 50 0 0 1 110 65"
        fill="none" stroke="#1e293b" strokeWidth="8" />
      {/* Colored arc */}
      <path d="M10 65 A50 50 0 0 1 110 65"
        fill="none" stroke="url(#fng)" strokeWidth="8"
        strokeDasharray={`${(v / 100) * 157} 157`} />
      {/* Needle */}
      <line x1="60" y1="65"
        x2={60 + 40 * Math.cos((angle * Math.PI) / 180)}
        y2={65 + 40 * Math.sin((angle * Math.PI) / 180)}
        stroke={color} strokeWidth="2.5" />
    </svg>
  );
}
```

The important insight from our research: Fear & Greed is a lagging indicator for BTC. Our [Granger causality tests](/posts/series/owuw-beat/04-data-collection-pipeline/) showed BTC price movements *cause* FNG changes, not the other way around. The gauge is there for context, not for trading signals.

But at extremes (FNG > 90 = Extreme Greed), the data tells a counterintuitive story: it's actually a momentum signal, not a contrarian one. BTC averaged +32% in the month following extreme greed readings, with an 85% win rate. The gauge helps me spot those moments.

## The Flask API: Lessons From Production

The backend taught me more about production resilience than any textbook.

### The .env Deadlock Disaster

The most painful bug was a file deadlock. The original code called `load_dotenv()` on every API request — five different endpoints, each reopening the `.env` file. On macOS, when the file was being written by another process (the agent updating API keys), `load_dotenv()` would hang. Indefinitely.

One deadlocked call would hold the Flask worker. Another request would hit the same lock. Within minutes, all workers were frozen. The dashboard showed a loading spinner forever.

The fix was embarrassingly simple:

```python
# BEFORE: Called on every request (5 places!)
@app.route('/api/signal')
def signal():
    load_dotenv()  # ← potential deadlock
    key = os.getenv('BINANCE_API_KEY')
    ...

# AFTER: Load once at startup with hardcoded fallbacks
_ENV_DEFAULTS = {
    'BINANCE_API_KEY': '...',
    'BINANCE_API_SECRET': '...',
    'FRED_API_KEY': '...',
}

try:
    if os.path.exists(ENV_PATH):
        load_dotenv(ENV_PATH)
except OSError:
    print("[STARTUP] .env file deadlocked, using defaults")

for _k, _v in _ENV_DEFAULTS.items():
    if not os.getenv(_k):
        os.environ[_k] = _v
```

Load the `.env` once at startup. If it fails, use hardcoded defaults. Never touch the file again during runtime. This pattern — **fail-safe defaults with one-time file reads** — should be standard for any always-on service.

### Authentication That Doesn't Embarrass You

The original login was an HTML string inside a Python route. The V2 version uses proper session-based auth with rate limiting:

```python
_login_attempts = {}
MAX_ATTEMPTS = 5
LOCKOUT_SECONDS = 300

def _is_locked(ip):
    rec = _login_attempts.get(ip)
    if not rec:
        return False
    if rec['count'] >= MAX_ATTEMPTS:
        if time.time() - rec['first'] < LOCKOUT_SECONDS:
            return True
        _login_attempts.pop(ip, None)
    return False
```

Five failed attempts from an IP triggers a 5-minute lockout. Passwords are hashed with `scrypt` via Werkzeug. Session cookies use `SameSite=Lax`. It's not Fort Knox, but it's appropriate for a trading dashboard that's primarily accessed via localhost or Cloudflare Tunnel with its own authentication layer.

### Performance Tracking: TWR, Not Simple Returns

The `/api/performance_live` endpoint calculates Time-Weighted Returns (TWR), which matters because I make deposits over time. Simple return calculation would be distorted by new capital.

The performance tracker (`research/performance_tracker.py`) snapshots daily at 07:30 KST via a cron job. The live endpoint calculates returns from the last snapshot to the current moment, combining:

- Spot balance from Binance API
- Earn positions (flexible savings) from Binance Earn API
- Historical snapshots from the tracker database

This gives accurate portfolio performance even with irregular deposits — which is exactly what happens when you're funding a trading account gradually.

## The Design System

The V2 dashboard uses a custom Tailwind theme that I'm genuinely proud of. The agent created a cohesive design system from scratch:

```javascript
// tailwind.config.js (simplified)
module.exports = {
  theme: {
    extend: {
      colors: {
        'owuw-bg': '#0a0e17',
        'owuw-card': '#111827',
        'owuw-border': '#1e293b',
        'owuw-accent': '#3b82f6',
        'bull': '#22c55e',
        'bear': '#ef4444',
        'neutral': '#eab308',
      }
    }
  }
}
```

Three semantic colors — bull (green), bear (red), neutral (yellow) — used consistently everywhere. Regime is BULL? Green. Portfolio down? Red. Macro signal near zero? Yellow. You never have to read the label; the color tells you the story.

The card component pattern is consistent across all pages: dark background (`owuw-card`), subtle border (`owuw-border`), border highlight on hover (`owuw-border-hover`). Every number uses `tabular-nums` for proper alignment in columns.

## Pages Beyond the Main Dashboard

The V2 dashboard has nine additional pages:

**Performance Analysis** — Portfolio return chart with benchmark overlay (buy-and-hold BTC). Shows TWR, excess return, Sharpe ratio, and maximum drawdown with interactive tooltips. The chart uses [Recharts](https://recharts.org/) `AreaChart` with a gradient fill — green when above benchmark, red when below.

**Market Report** — Renders the daily market analysis that the agent generates every morning at 07:00 KST. Markdown rendered to HTML. Includes regime analysis, macro factor breakdown, and allocation recommendation.

**Investment Memo** — The formal investment memorandum document. This is what an institutional investor would expect: strategy description, risk parameters, backtest results, governance process. Generated and updated automatically after each board meeting.

**R&D Research** — Experiment results from the (now shutdown) R&D agent. Each experiment shows the hypothesis, methodology, backtest results, and the agent's recommendation. Historical record of all 200+ experiments.

**Board Minutes** — Full transcripts of the AI board meetings. Nine directors debating model changes, with votes recorded. Each meeting includes the proposal, discussion points, voting results, and implementation plan.

**Timeline** — Chronological event log. Model version changes, board decisions, deposit events, rebalancing executions. A complete audit trail.

**Periodic Reports** — Weekly and monthly summaries generated automatically.

**Blog** — The English-language report that gets published to the external blog. Generated daily at 10:00 KST.

**Model Profile** — Technical specification of the current model (V5.3): parameters, allocation rules, defense triggers, backtest statistics.

## Practical Prompts: Building Your Own

If you're building a trading dashboard for your own system, here are prompts that actually work:

### Prompt: Initialize the Dashboard Project

```
Create a trading dashboard with this stack:
- Electron for desktop app
- React 18 + Vite for frontend
- Tailwind CSS for styling
- Recharts for charts

The dashboard connects to a Flask API at localhost:5555 with these endpoints:
- GET /api/signal → {regime, regime_score, btc_price, allocation_pct, macro_signal, factors: {}}
- GET /api/performance_live → {annualized_return_pct, sharpe, mdd, chart_data: [{date, value}]}
- GET /api/account → {total_usd, positions: []}

Create a main dashboard page with:
1. Top row: 6 KPI cards (price, regime, allocation, total assets, model return, fear & greed)
2. Middle row: 3 panels (regime factors detail, defense system status, macro signal bar)
3. Bottom: performance chart with benchmark overlay

Use a dark theme with semantic colors: green for bullish, red for bearish, yellow for neutral.
```

### Prompt: Add Polling with Custom Hook

```
Create a useApi custom React hook that:
1. Takes a fetch function and polling interval (default 30s)
2. Calls the function immediately on mount
3. Sets up interval polling
4. Handles cleanup on unmount (no state updates after unmount)
5. Returns {data, error, loading}

Then use it in Dashboard.jsx like:
const { data: signal } = useApi(() => api.signal(), 30000);
const { data: perf } = useApi(() => api.performance(), 60000);
```

### Prompt: Flask API with Fail-Safe Environment Loading

```
Refactor this Flask API to:
1. Load .env ONCE at startup (not per-request)
2. Include hardcoded fallback values for all API keys
3. If .env read fails (OSError/deadlock), use fallbacks silently
4. Add IP-based rate limiting for login (5 attempts, 5-min lockout)
5. Use scrypt password hashing via werkzeug
6. Add CORS support for localhost Electron app
```

## What I'd Do Differently

**Start with the API contract.** I built the Flask endpoints organically as features were needed. If I started over, I'd define the API schema first — request/response types, refresh semantics, error formats — and build both frontend and backend against that contract.

**Use Server-Sent Events instead of polling.** WebSocket is overkill for a dashboard that primarily displays data. SSE would give me push updates with simpler infrastructure: the Flask backend watches for file changes and streams updates. No bidirectional communication needed.

**Build mobile-first.** The V2 dashboard is primarily a desktop app (Electron), but I still check it from my phone via Cloudflare Tunnel. The responsive design works, but it's an afterthought. A mobile-first approach would have saved time.

**Add alerting.** The dashboard shows state but doesn't notify me of state changes. I rely on the Telegram bot for alerts (regime changes, rebalancing events). Integrating push notifications into the Electron app — especially for crash defense activation — would close the loop.

## The Bigger Picture

The dashboard seems like a nice-to-have. It's not. It changed how I interact with the entire trading system.

Before the dashboard, I operated through conversation. Every check was a question, every answer was text. The information was accurate but sequential — I could only process one thing at a time.

After the dashboard, I operate through observation. I glance at the screen and absorb the complete system state in seconds. Regime is BULL, macro score is +35, allocation is 90%, crash defense is inactive, portfolio is up 12% vs benchmark. All of that in one look.

This is the difference between managing a system and monitoring a system. Managing requires active engagement — asking, interpreting, deciding. Monitoring requires passive awareness — seeing, recognizing, intervening only when necessary.

For an autonomous trading system, monitoring is the right paradigm. The system makes its own decisions (regime detection, allocation, rebalancing). My job is to watch for anomalies and intervene when something looks wrong. A dashboard is the right tool for that job.

In the [next post](/posts/series/owuw-beat/08-rebalancing-and-earn/), I'll cover the rebalancing engine — how the system automatically adjusts positions every 10 days based on the regime signal, and how it manages idle USDT through Binance Earn to generate yield while waiting for the next allocation change.

---

*This is Part 7 of the [Building OWUW Beat](/posts/series/owuw-beat/) series. Start from [Part 1: Why I Built a BTC Trading Bot](/posts/series/owuw-beat/01-why-i-built-a-btc-trading-bot/) or go back to [Part 6: AI Board of Directors](/posts/series/owuw-beat/06-ai-board-of-directors/).*
