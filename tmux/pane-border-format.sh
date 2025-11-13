#!/bin/bash
# Script to generate pane border format with git info

pane_path="$1"
cd "$pane_path" 2>/dev/null || exit 1

# Use full path
dir="$pane_path"

# Check if in a git repo
if git rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        # Check for uncommitted changes (dirty)
        if git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null; then
            dirty=""
        else
            dirty="*"
        fi

        # Check for commits ahead/behind remote
        arrows=""
        if upstream=$(git rev-parse --abbrev-ref @{u} 2>/dev/null); then
            # Get left (ahead) and right (behind) counts
            counts=$(git rev-list --left-right --count HEAD...@{u} 2>/dev/null)
            if [ -n "$counts" ]; then
                left=$(echo "$counts" | awk '{print $1}')
                right=$(echo "$counts" | awk '{print $2}')

                # Add down arrow if behind
                [ "$right" -gt 0 ] && arrows+="⇣"
                # Add up arrow if ahead
                [ "$left" -gt 0 ] && arrows+="⇡"
            fi
        fi

        # Build status string with space if there are any indicators
        status=""
        [ -n "$dirty" ] || [ -n "$arrows" ] && status=" $dirty$arrows"

        echo "$dir  $branch$status"
    else
        echo "$dir"
    fi
else
    echo "$dir"
fi
