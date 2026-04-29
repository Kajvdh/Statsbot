# Statsbot - Project Overview

## Purpose
A real-time IRC statistics bot (inspired by pisg) that connects to IRC networks, collects channel statistics live, and serves a Flask web dashboard. Replaces pisg's static log-parsing approach with a live connection model.

## Tech Stack
- **Language:** Python 3.11+
- **Web framework:** Flask (serves on port 8033 by default)
- **Database:** SQLite with WAL mode (default: `data/stats.db`)
- **Auth:** bcrypt for password hashing
- **Config:** YAML (`config/config.yml`)
- **i18n:** Custom lightweight PO file loader (locale/en_US.po, pt_PT.po, fr_FR.po, it_IT.po)
- **No external deps beyond:** flask, pyyaml, bcrypt

## Architecture
Single-process, multi-threaded:
- **asyncio event loop** runs IRC connectors (one per network) + a scheduler
- **Flask web dashboard** runs in a daemon thread
- Shared state via `asyncio.Queue` (`reload_queue` in main.py) for runtime network/channel management

**Data flow:** IRC messages → `bot/connector.py` (RFC 1459 parser) → `bot/sensors.py` (event handlers) → `database/models.py` (SQLite). Web layer reads directly from SQLite.

## Key Modules
- `main.py` — entry point, CLI args (--setup, --web-only, --init-db, --config)
- `bot/connector.py` — async IRC connection, TLS, RFC 1459 parsing, WHO/WHOX
- `bot/sensors.py` — all stat tracking (words, smileys, karma, monologues, kicks, modes, etc.)
- `bot/parser.py` — message text analysis (word count, caps, violence, foul language)
- `bot/auth.py` — bcrypt password auth, session management, auto-auth via hostmask
- `bot/scheduler.py` — daily/weekly/monthly stat period resets
- `database/models.py` — SQLite schema, all queries, automatic migrations
- `irc/commands.py` — channel commands (!stats, !top, !quote)
- `irc/pm_commands.py` — PM admin interface
- `web/dashboard.py` — Flask routes: landing, network pages, JSON API
- `web/pisg_page.py` — full pisg-style channel stats HTML page
- `i18n.py` — PO file loader with `t()` translation function

## Database
- SQLite with WAL mode, auto-migrates on startup
- Key tables: `nicks`, `stats` (period: 0=all-time, 1=today, 2=week, 3=month), `networks`, `channels`, `masters`, `ignores`
- Config seeds DB on first run only — after that, DB is authoritative
