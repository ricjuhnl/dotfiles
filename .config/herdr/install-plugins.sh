#!/usr/bin/env bash
# Install the herdr plugins listed in plugins.list (next to this script).
# Run after stowing dotfiles on a fresh machine:  ~/.config/herdr/install-plugins.sh
set -euo pipefail

LIST="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/plugins.list}"
[ -f "$LIST" ] || { echo "plugin list not found: $LIST" >&2; exit 1; }

while IFS= read -r line || [ -n "$line" ]; do
  line="${line%%#*}" # strip comments
  read -r -a args <<<"$line"
  [ ${#args[@]} -gt 0 ] || continue
  echo "herdr plugin install ${args[*]} -y"
  herdr plugin install "${args[@]}" -y
done <"$LIST"

echo "all plugins installed"
