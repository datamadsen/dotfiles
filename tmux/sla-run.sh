#!/bin/sh
# SLA Management System runner.
# Run an iis expresss instance with the site. The SLA site id is 8.

SESSION_NAME=sla-run
WORKING_DIR="/cygdrive/c/Program Files (x86)/IIS Express"


tmux has-session -t $SESSION_NAME 2>/dev/null
if [ "$?" -eq 1 ] ; then 
  # no session found, create one.
  tmux new-session -d -s $SESSION_NAME

	# iisexpres
  tmux send-keys "cd \"$WORKING_DIR\"" C-m
	tmux rename-window iisexpress
  tmux send-keys "./iisexpress /siteid:8" C-m

  # select first window
  tmux select-window -t $SESSION_NAME:1
fi

echo "Session created. Attach to it with \`tmux attach -t $SESSION_NAME\`"
