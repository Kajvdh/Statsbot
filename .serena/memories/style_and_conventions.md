# Code Style and Conventions

## General
- Python 3.11+ features are used freely
- No external dependencies beyond flask, pyyaml, bcrypt
- Module docstrings present at top of each file (brief, referencing what the module mirrors from pisg/stats.mod)
- Function/class docstrings are present but not mandatory (pylint C0114/C0115/C0116 are disabled)

## Naming
- **snake_case** for functions, methods, variables, and module names
- **PascalCase** for classes (e.g. `Sensors`, `CommandHandler`, `IRCConnector`)
- Private methods/attributes prefixed with underscore (e.g. `_flood_check`, `_quote_counters`)
- Config keys from pisg use PascalCase to match pisg's naming (e.g. `ActiveNicks`, `ShowBigNumbers`, `WordLength`)

## Type Hints
- Used in function signatures (from `typing` module: `Optional`, `List`, `Tuple`, `Dict`, `Callable`)
- Not exhaustive — some internal helpers omit them

## Patterns
- Context manager (`get_conn()`) for all database access
- Classes for stateful components (Sensors, CommandHandler, IRCConnector, AuthManager)
- Compiled regex constants at module level (e.g. `MSG_RE`, `URL_RE`, `CTRL_RE`)
- Logging via `logging.getLogger("module_name")` at module level
- Config accessed via dict lookups with `.get()` defaults throughout

## URL Routing
- Case-insensitive with canonical redirects (recent convention)

## i18n
- Use `t(key, lang, **kwargs)` for translatable strings
- PO files in `locale/` directory
