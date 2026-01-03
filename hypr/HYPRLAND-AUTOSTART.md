# Hyprland Autostart Setup

Hyprland is automatically started on login via a **systemd user service**.

## Service Location

```
~/.config/systemd/user/hyprland.service
```

## How It Works

1. The service is enabled for the `default.target`, meaning it starts automatically when you log in to a TTY
2. It runs `start-hyprland` which handles the Hyprland startup process
3. If Hyprland crashes, systemd will automatically restart it after 1 second

## Service Configuration

```ini
[Unit]
Description=Hyprland Wayland Compositor
After=graphical-session-pre.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/start-hyprland
Restart=on-failure
RestartSec=1
TimeoutStopSec=10

[Install]
WantedBy=default.target
```

## Useful Commands

```bash
# Check service status
systemctl --user status hyprland.service

# View service logs
journalctl --user -u hyprland.service

# Restart the service (will restart Hyprland)
systemctl --user restart hyprland.service

# Disable autostart
systemctl --user disable hyprland.service

# Re-enable autostart
systemctl --user enable hyprland.service

# Reload after editing the service file
systemctl --user daemon-reload
```
