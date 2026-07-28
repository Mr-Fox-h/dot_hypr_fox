#!/bin/bash
# Count windows in the special:minimized workspace
count=$(hyprctl clients -j 2>/dev/null | jq -r '[.[] | select(.workspace.name == "special:minimized")] | length')

if [ "$count" -gt 0 ]; then
    # Get window titles for the tooltip
    titles=$(hyprctl clients -j 2>/dev/null | jq -r '.[] | select(.workspace.name == "special:minimized") | .title' | tr '\n' ' | ' | sed 's/ | $//')
    echo "{\"text\": \"  $count\", \"tooltip\": \"Minimized ($count):\\n$titles\", \"class\": \"minimized-active\"}"
else
    # Output empty text if no windows are minimized so it hides gracefully
    echo "{\"text\": \"\", \"class\": \"minimized-inactive\"}"
fi
