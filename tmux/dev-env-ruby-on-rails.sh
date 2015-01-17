#!/bin/sh
# RoR development, for me, consists of:
#   1. Development, in Vim.
#   2. Running tests, through Guard.
#   3. Messing around in RoR console.
#   4. Running the development webserver.
#   5. Tailing logs.

SESSION_NAME=${PWD##*/} 

tmux has-session -t $SESSION_NAME 2>/dev/null
if [ "$?" -eq 1 ] ; then 
  # no session found, create one.
  tmux new-session -d -s $SESSION_NAME

  # editor
  tmux rename-window "vim"
  tmux send-keys "vim +NERDTree" C-m

  # tests
  tmux new-window -t $SESSION_NAME -n "test"
  tmux send-keys "guard" C-m

  # ruby on rails console
  tmux new-window -t $SESSION_NAME -n "console"
  tmux send-keys "rails console" C-m

  # webrick
  tmux new-window -t $SESSION_NAME -n "server"
  tmux send-keys "rails server" C-m

  # log tailing
  tmux new-window -t $SESSION_NAME -n "logs"
  tmux send-keys "tail -f log/development.log" C-m

  # select first window
  tmux select-window -t $SESSION_NAME:1
fi

# attach the session
tmux -2 attach-session -t $SESSION_NAME
