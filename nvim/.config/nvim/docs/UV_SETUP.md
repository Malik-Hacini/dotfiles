# UV Setup (Optional)

NeoTex no longer requires `uv` for core functionality.

Tooling in this config is primarily managed by Mason (`:Mason`) and loaded from Mason's bin directory inside Neovim.

Use `uv` only if you want it for your own Python workflows outside this config.

## Install UV

See the official installer and docs:

- https://github.com/astral-sh/uv

## Verify

```bash
uv --version
```

## NeoTex Recommendation

- For editor-integrated LSP/format/lint tooling, prefer Mason packages.
- Keep shell-level Python toolchains separate from Neovim tooling unless you have a specific reason to unify them.
