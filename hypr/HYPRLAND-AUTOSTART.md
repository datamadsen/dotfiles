# Hyprland Autostart Setup

Hyprland is started by the **login shell on tty1**. agetty autologs `tmadsen` in on tty1 (`/etc/systemd/system/getty@tty1.service.d/autologin.conf`), zsh runs `~/.zprofile`, and that `exec`s `start-hyprland`.

## Files

```
~/.zprofile -> ~/dotfiles/zsh/zprofile
```

```zsh
if [[ -z $WAYLAND_DISPLAY && $XDG_VTNR -eq 1 && -z $SSH_CONNECTION && -z $TMUX ]]; then
  exec start-hyprland
fi
```

## How It Works

1. The shell only runs after logind has registered the tty1 session, so Hyprland always finds a seat.
2. `exec` replaces the shell with Hyprland. When Hyprland exits (or crashes), the tty logs out, agetty autologs in again, and Hyprland restarts. This replaces the old service's `Restart=on-failure`.
3. The guards keep it from firing inside an existing Wayland session, over SSH, in tmux, or on another VT.

## History

Until 2026-10-18 Hyprland was started by a systemd user service, `~/.config/systemd/user/hyprland.service`, hooked to `default.target`. After `loginctl enable-linger tmadsen` (2026-10-17) the user manager started at boot, before the tty1 login, and Hyprland aborted with `CBackend::create() failed!` because no seat session existed yet. `start-hyprland` exits 0 even when Hyprland dumps core, so the service never restarted it. The unit file is still there but **disabled**; do not re-enable it while lingering is on.

## Useful Commands

```bash
# Hyprland log of the running instance
cat "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/hyprland.log"

# Crash dumps
coredumpctl list Hyprland

# Stop autostart temporarily: log in on tty2 instead, or comment out the exec line.
```
