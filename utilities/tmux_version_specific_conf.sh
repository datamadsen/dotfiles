#!/bin/bash

verify_tmux_version () {
    tmux_home=~/.tmux
    tmux_version="$(tmux -V | cut -c 6-)"

    if [[ $(echo "$tmux_version >= 2.9" | bc) -eq 1 ]] ; then
        tmux source-file "~/.utilities/new-tmux-dark.sh"
        exit
    elif [[ $(echo "$tmux_version >= 2.6" | bc) -eq 1 ]] ; then
        tmux source-file "/home/tmadsen/.utilities/old-tmux-dark.sh"
        exit
    else
        exit
    fi
}

verify_tmux_version
