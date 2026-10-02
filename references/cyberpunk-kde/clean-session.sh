#!/bin/bash
# Remove conky entries from KDE LegacySession to prevent duplicate launches.
# KDE saves all running apps at logout, including conky.
# This causes a duplicate when systemd also starts conky at login.
KSMSERVER_RC="$HOME/.config/ksmserverrc"
[ -f "$KSMSERVER_RC" ] || exit 0

python3 -c "
import re
with open('$KSMSERVER_RC', 'r') as f:
    content = f.read()

# Remove entire LegacySession section (KDE4 cruft that causes conky duplication)
new_content = re.sub(r'\[LegacySession:.*?\](?:\n(?!^\[).*)*', '', content, flags=re.MULTILINE)
new_content = re.sub(r'\n{3,}', '\n\n', new_content)

with open('$KSMSERVER_RC', 'w') as f:
    f.write(new_content)
"
