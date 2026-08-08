# Hermes Agent Installation

## Installation Summary

Hermes Agent has been successfully installed on this system.

**Installation Details:**
- **Version:** v0.20.0 (2026.8.3)
- **Installed:** 2026-08-08
- **Command Location:** `/usr/local/bin/hermes`
- **Installation Directory:** `/usr/local/lib/hermes-agent`
- **Python Version:** 3.11.15
- **OpenAI SDK:** 2.24.0

## Installation Method

The installation was performed using the official Hermes Agent installer script:

```bash
curl -fsSL --cacert /root/.ccr/ca-bundle.crt https://hermes-agent.nousresearch.com/install.sh | bash
```

## Dependencies Verified

The installer automatically verified and installed the following dependencies:
- ✓ Python 3.11.15
- ✓ Git 2.43.0
- ✓ Node.js v22.22.2 (for browser tools)
- ✓ ripgrep 14.1.0 (for fast file search)
- ✓ ffmpeg (for TTS voice messages)
- ✓ uv 0.12.3 (Python package manager)

## Quick Start

To start using Hermes Agent, run:

```bash
hermes
```

### Common Commands

- `hermes model` — Select LLM provider
- `hermes tools` — Configure available tools
- `hermes setup` — Run full setup wizard
- `hermes version` — Check version and update status

## Documentation

For more information, visit: https://hermes-agent.nousresearch.com/docs/getting-started/installation

## Next Steps

1. Configure your LLM provider: `hermes model`
2. Set up tools: `hermes tools`
3. Run the setup wizard: `hermes setup`
