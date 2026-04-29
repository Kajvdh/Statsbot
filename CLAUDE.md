# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is Statsbot?

A real-time IRC statistics bot (Python 3.11+) that connects to IRC networks, collects channel statistics live, and serves a Flask web dashboard. It replaces pisg's static log-parsing approach with a live connection model. The `pisg:` config section uses pisg-compatible option names.

## Commands

```bash
# Setup
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# Run
python main.py                          # full bot + web dashboard
python main.py --web-only               # web dashboard only
python main.py --init-db                # initialize DB and exit
python main.py --setup                  # interactive master password wizard
python main.py --config path/to/cfg.yml # custom config path

# Lint (CI runs both)
flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
pylint $(git ls-files '*.py') --disable=C0114,C0115,C0116 --disable=R0903,R0912,R0913,R0914,R0915 --disable=W0703,W0719 --fail-under=7.0

# Smoke test (no formal test suite — CI runs this)
python -c "
from database.models import set_db_path, init_db
set_db_path('/tmp/ci_test.db')
init_db()
from bot.parser import parse_message
from bot.auth import hash_password, verify_password
assert verify_password('test', hash_password('test'))
print('OK')
"
```

## Architecture

**Single-process, multi-threaded:** asyncio event loop runs IRC connectors (one per network) + a scheduler. Flask web dashboard runs in a daemon thread. They share state via an `asyncio.Queue` (`reload_queue` in main.py) for runtime add/remove of networks and channels.

**Data flow:** IRC messages → `bot/connector.py` (RFC 1459 parser) → `bot/sensors.py` (event handlers that update stats) → `database/models.py` (SQLite with WAL mode). The web layer reads directly from SQLite.

**Key modules:**
- `bot/connector.py` — async IRC connection, TLS, RFC 1459 parsing, WHO/WHOX handling
- `bot/sensors.py` — all stat tracking: words, smileys, karma, monologues, kicks, modes, etc.
- `bot/parser.py` — message text analysis (words, caps, violence, foul language detection)
- `bot/auth.py` — bcrypt password auth, session management, auto-auth via hostmask
- `bot/scheduler.py` — daily/weekly/monthly stat period resets
- `database/models.py` — SQLite schema, all queries, automatic migrations. Stats use a period system: 0=all-time, 1=today, 2=week, 3=month
- `irc/commands.py` — channel commands (!stats, !top, !quote)
- `irc/pm_commands.py` — PM admin interface (identify, ignore, master, network/channel management)
- `web/dashboard.py` — Flask routes: landing page, network pages, JSON API
- `web/pisg_page.py` — full pisg-style channel stats HTML page
- `i18n.py` — lightweight PO file loader; translations in `locale/` (en_US, pt_PT, fr_FR, it_IT)

**Database:** SQLite, path configurable (default `data/stats.db`). Schema auto-migrates on startup. Key tables: `nicks` (per-network, per-channel), `stats` (per-nick per-period counters), `networks`, `channels`, `masters`, `ignores`.

**Config:** `config/config.yml` (copy from `config.yml.example`). Seeds the DB on first run only — after that, the DB is authoritative. Runtime changes via PM commands update the DB directly.

**No external deps beyond:** flask, pyyaml, bcrypt (see requirements.txt).

## Development notes

- No formal test framework — tests are inline `python -c` smoke tests
- URL routing is case-insensitive with canonical redirects (see recent commits)
- When adding/changing config options, update `DOCS.md`
