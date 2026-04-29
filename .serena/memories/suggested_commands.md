# Suggested Commands

## Setup
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Running
```bash
python main.py                          # full bot + web dashboard
python main.py --web-only               # web dashboard only (no IRC)
python main.py --init-db                # initialize database and exit
python main.py --setup                  # interactive master password wizard
python main.py --config path/to/cfg.yml # custom config file
```

## Linting (CI runs both)
```bash
# flake8 — syntax errors and undefined names only
flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics

# pylint — with project-specific disables, fail-under 7.0
pylint $(git ls-files '*.py') \
  --disable=C0114,C0115,C0116 \
  --disable=R0903,R0912,R0913,R0914,R0915 \
  --disable=W0703,W0719 \
  --fail-under=7.0
```

## Testing (no formal test suite — CI runs a smoke test)
```bash
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

## System Utilities (macOS/Darwin)
```bash
git status / git log / git diff
ls, cd, grep, find       # standard unix commands (BSD variants on macOS)
```
