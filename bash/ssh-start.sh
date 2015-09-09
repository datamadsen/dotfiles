#!/bin/sh

export SSH_AUTH_SOCK=~/.ssh-auth-socket

ssh-add -l > /dev/null 2> /dev/null
if [ $? -eq 2 ]; then
  rm ~/.ssh-auth-socket # otherwise bind addr already in use.
  eval `ssh-agent -s -a ~/.ssh-auth-socket`
  echo "add private key to authentication agent:"
  ssh-add
fi
