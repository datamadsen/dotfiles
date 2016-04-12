#!/bin/sh
# SLA Management System development
#   1. Source code version control.
#   2. Development.
#
# The directory is known: ~/source/SLAManagementSystem

SESSION_NAME=irc

tmux has-session -t $SESSION_NAME 2>/dev/null
if [ "$?" -eq 1 ] ; then 
  # no session found, create one.
  tmux new-session -d -s $SESSION_NAME

	# apati.slack.com
	tmux send-keys "irssi -c apati" C-m
	tmux rename-window apati

  # freenode
  tmux new-window -t $SESSION_NAME -n "freenode"
	tmux send-keys "irssi -c freenode" C-m

  # select first window
  tmux select-window -t $SESSION_NAME:1
fi

echo "Session created. Attach to it with \`tmux attach -t $SESSION_NAME\`"
