#### COLOUR (Solarized dark)
case `tmux -V` in
    'tmux 2.9a')
        # default statusbar colors
        set-option -g status-style bg=black,fg=white
        set-option -g status-attr-style default

        # default window title colors
        set-window-option -g window-status-fg-style white
        set-window-option -g window-status-bg-style black
        set-window-option -g window-status-attr-style default

        # active window title colors
        set-window-option -g window-status-current-fg-style blue
        set-window-option -g window-status-current-bg-style default
        set-window-option -g window-status-current-attr-style default

        # pane border
        set-option -g pane-border-fg-style black
        set-option -g pane-active-border-fg-style brightgreen

        # message text
        set-option -g message-bg-style black
        set-option -g message-fg-style brightred

        # pane number display
        set-option -g display-panes-active-colour blue
        set-option -g display-panes-colour brightred

        # clock
        set-window-option -g clock-mode-colour blue
    ;;
    'tmux 2.6')
        # default statusbar colors
        set-option -g status-bg black
        set-option -g status-fg white
        set-option -g status-attr-style default

        # default window title colors
        set-window-option -g window-status-fg-style white
        set-window-option -g window-status-bg-style black
        set-window-option -g window-status-attr-style default

        # active window title colors
        set-window-option -g window-status-current-fg-style blue
        set-window-option -g window-status-current-bg-style default
        set-window-option -g window-status-current-attr-style default

        # pane border
        set-option -g pane-border-fg-style black
        set-option -g pane-active-border-fg-style brightgreen

        # message text
        set-option -g message-bg-style black
        set-option -g message-fg-style brightred

        # pane number display
        set-option -g display-panes-active-colour blue
        set-option -g display-panes-colour brightred

        # clock
        set-window-option -g clock-mode-colour blue
    ;;
esac

