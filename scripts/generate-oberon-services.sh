#!/usr/bin/env bash
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$SELF_DIR/../docs/services.md"

if ! command -v nix &>/dev/null; then
  echo "nix not found, skipping oberon services page update" >&2
  exit 0
fi

if ! command -v jq &>/dev/null; then
  echo "jq not found, skipping oberon services page update" >&2
  exit 0
fi

nix eval '.#nixosConfigurations.oberon.config.kibadda.services' --json 2>/dev/null | jq -r '
def bk_text(s):
  if (s.backup.archive | length) > 0 and (s.backup.sync | length) > 0 then     "archive:<br>\( s.backup.archive | join("<br>") )<br>sync:<br>\( s.backup.sync | join("<br>") )"
  elif (s.backup.archive | length) > 0 then "archive:<br>\( s.backup.archive | join("<br>") )"
  elif (s.backup.sync | length) > 0 then "sync:<br>\( s.backup.sync | join("<br>") )"
  else "—" end;
def port_text(s): if s.port then ":\(s.port)" else "socket" end;
def section_or_empty(s): if s.section then s.section else "" end;

"# Oberon Services",
"",
"## Table of Contents",
"",
(to_entries | sort_by(.key)[] | "- [\(.value.description)](#\(.key))"),
"",
(to_entries | sort_by(.key)[] |
  "## \(.key)",
  "",
  "| Key | Value |",
  "|-----|-------|",
  "| Name | \(.key) |",
  "| Description | \(.value.description) |",
  "| Subdomain | \(.value.subdomain) |",
  "| URL | \(.value.url) |",
  "| Open | \(if .value.open then "✓" else "" end) |",
  "| Auth | \(.value.auth) |",
  "| Port | \(port_text(.value)) |",
  "| Section | \(section_or_empty(.value)) |",
  "| Backup | \(bk_text(.value)) |",
  ""
)
' > "$OUT"

echo "Updated $OUT"
