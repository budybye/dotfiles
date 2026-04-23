# AI Agent Configuration

This directory contains configuration files for the pi coding agent.

## Configuration Structure

- `models.json` - Custom model providers and configurations
- `settings.json` - Default settings and preferences
- `prompts/` - Custom prompt templates
- `AGENT.md` - Agent-specific instructions (this file)

## Usage

The pi agent will automatically load these configurations. You can override settings per project by creating a `.pi/` directory in your project root with custom configurations.

## Response Language

By default, the agent responds in English. To specify a different language:
- Set the `PI_AGENT_LANGUAGE` environment variable
- Or add `language: "ja"` (or preferred language code) to your project's `.pi/settings.json`

Example settings.json for Japanese responses:
```json
{
  "language": "ja",
  "locale": "ja-JP"
}
```

## Common Commands

- `/model` - Switch between configured models
- `/settings` - Modify runtime settings
- `/tree` - Navigate session history
- `/compact` - Manually compact context
- `/reload` - Reload configurations

## Custom Models

To use custom models:
1. Ensure the model server is running (e.g., Ollama on localhost:11434)
2. Use `/model` to select your desired model
3. The configuration will persist across sessions

## Adding API Keys

API keys can be set via environment variables:
- `ANTHROPIC_API_KEY` for Anthropic models
- `OPENAI_API_KEY` for OpenAI models
- `GEMINI_API_KEY` for Google Gemini models

Or store them in `~/.pi/agent/auth.json` for better security.