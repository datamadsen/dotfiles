#!/bin/sh
# SLA Management System development
#   1. Source code version control.
#   2. Development.
#
# The directory is known: ~/source/SLAManagementSystem

SESSION_NAME=sla-dev
WORKING_DIR=~/source/SLAManagementSystem

tmux has-session -t $SESSION_NAME 2>/dev/null
if [ "$?" -eq 1 ] ; then 
  # no session found, create one.
  tmux new-session -d -s $SESSION_NAME

	# terminal
  tmux send-keys "cd $WORKING_DIR" C-m
  tmux send-keys "clear" C-m
	tmux send-keys "git lg" C-m
	tmux rename-window git

  # editor
  tmux new-window -t $SESSION_NAME -n "source"
  tmux send-keys "cd $WORKING_DIR" C-m
  tmux send-keys "clear" C-m
  tmux send-keys "vim +NERDTree" C-m

  # select first window
  tmux select-window -t $SESSION_NAME:1
fi

echo "Session created. Attach to it with \`tmux attach -t $SESSION_NAME\`"
