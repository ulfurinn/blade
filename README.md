# Blade

Semantic search for Obsidian vaults.

It runs as its own server outside of Obsidian.

## Prerequisites

- ollama
- pgvector
- pandoc
- Elixir

### LLM server

This has been tested with [Ollama](https://ollama.com/download). After installing and starting the server, run `ollama pull nomic-embed-text`.

### PgVector

Install and set up PostgreSQL as appropriate for your platform.

Install [PgVector](https://github.com/pgvector/pgvector?.tab=readme-ov-file#installation).

Create a database to hold your data. Check that `CREATE EXTENSION vector` works.

## Installation

```sh
MIX_ENV=prod \
  DATABASE_URL=postgres://user:pass@host/database \
  mix dist
```

This will create a self-contained build in `$(pwd)/_build/prod/rel/blade`. Make note of this path for the next steps, or move it to a location of your choice.

## Start on boot

### MacOS

Create a file in `~/Library/LaunchAgents/net.ulfurinn.blade.plist` containing the following (replace comments with real values).

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>EnvironmentVariables</key>
    <dict>
      <key>DATABASE_URL</key>
      <string><!-- postgres://user:pass@host/database - same as you used before --></string>
      <key>PORT</key>
      <string><!-- the port to listen on --></string>
      <key>VAULT_ROOT</key>
      <string><!-- absolute path to Obsidian vault --></string>
      <key>SECRET_KEY_BASE</key>
      <string><!-- run `mix phx.gen.secret` or use whichever other method to generate a longish random string --></string>
      <key>PANDOC</key>
      <string><!-- absolute path to pandoc --></string>
    </dict>
    <key>Label</key>
    <string>net.ulfurinn.blade</string>
    <key>ProgramArguments</key>
    <array>
      <string><!-- absolute path to distribution -->/bin/server</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string><!-- wherever you want -->/stdout.log</string>
    <key>StandardErrorPath</key>
    <string><!-- wherever you want -->/stderr.log</string>
    <key>WorkingDirectory</key>
    <string><!-- absolute path to distribution --></string>
  </dict>
</plist>
```

## Start manually

Run the `.../bin/server` command. All the same environment variables must be provided.

## Usage

Go to `http://localhost:${PORT}`.

The vault is scanned for changes every 10 minutes. The first scan may take a long time.