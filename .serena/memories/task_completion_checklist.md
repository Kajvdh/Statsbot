# Task Completion Checklist

After completing a task, run the following checks:

1. **flake8** — must pass with zero errors:
   ```bash
   flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
   ```

2. **pylint** — must score >= 7.0:
   ```bash
   pylint $(git ls-files '*.py') \
     --disable=C0114,C0115,C0116 \
     --disable=R0903,R0912,R0913,R0914,R0915 \
     --disable=W0703,W0719 \
     --fail-under=7.0
   ```

3. **Smoke test** — must print OK:
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

4. **If config options were added/changed** — update `DOCS.md`
