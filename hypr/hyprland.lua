-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/
-- Converted from hyprland.conf (hyprlang) to the Lua config format.

-- ================================
-- ENVIRONMENT VARIABLES
-- ================================

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Change to 1 if on a 1x display (then change scale to 1 in hl.monitor)
-- Change to something like 1.75 for fractional scaling (can work well with 1.66667 monitor scaling)
hl.env("GDK_SCALE", "1.5")

-- Cursor size
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Force all apps to use Wayland
hl.env("GDK_BACKEND", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- Make .desktop files available for wofi
hl.env("XDG_DATA_DIRS", "/usr/share:/usr/local/share:" .. os.getenv("HOME") .. "/.local/share")

-- Use XCompose file
hl.env("XCOMPOSEFILE", os.getenv("HOME") .. "/.XCompose")

-- NVIDIA environment variables
hl.env("NVD_BACKEND", "direct")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- ================================
-- MONITOR CONFIGURATION
-- ================================

-- Use single default monitor (see all monitors with: hyprctl monitors)
hl.monitor({ output = "eDP-1", mode = "2880x1800@120.00", position = "920x64", scale = 1.50 })
hl.monitor({ output = "DP-3", mode = "5120x2160@120.00", position = "0x0", scale = 1.25 })
-- hl.monitor({ output = "", mode = "5120x2160@120.00", position = "auto", scale = "auto" })

-- ================================
-- XWAYLAND / ECOSYSTEM SETTINGS
-- ================================

hl.config({
  xwayland = {
    force_zero_scaling = true,
  },

  -- Don't show update on first launch
  ecosystem = {
    no_update_news = true,
  },
})

-- ================================
-- AUTOSTART APPLICATIONS
-- ================================

hl.on("hyprland.start", function()
  -- swaync is started on demand via D-Bus activation (systemd user unit swaync.service)
  hl.exec_cmd("hypridle & waybar & fcitx5")
  hl.exec_cmd("swaybg -i ~/.config/farv/current/backgrounds/current-background -m fill")
  hl.exec_cmd("farv background random")
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("~/.config/tmux/btop-tmux.sh")
end)

-- ================================
-- LOOK AND FEEL
-- ================================

-- https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,

    border_size = 2,

    col = {
      active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },

    -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = false,

    -- Please see https://wiki.hypr.land/Configuring/Extra/Tearing/ before you turn this on
    allow_tearing = false,

    layout = "dwindle",
  },

  decoration = {
    rounding = 10,

    shadow = {
      enabled = true,
      range = 2,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },

    blur = {
      enabled = true,
      size = 3,
      passes = 1,

      vibrancy = 0.1696,
    },
  },

  animations = {
    enabled = true,
  },

  -- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
  dwindle = {
    preserve_split = true, -- You probably want this
    force_split = 2, -- Always split on the right
  },

  -- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
  master = {
    new_status = "master",
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
  },
})

-- Animation curves and animations
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = false })

-- ================================
-- INPUT CONFIGURATION
-- ================================

hl.config({
  input = {
    kb_layout = "us",
    kb_variant = "altgr-intl",
    kb_model = "",
    kb_options = "",
    kb_rules = "",

    follow_mouse = 1,

    sensitivity = 0.2, -- -1.0 - 1.0, 0 means no modification.
    -- accel_profile = "flat",
    scroll_method = "2fg",

    repeat_rate = 40,
    repeat_delay = 600,

    touchpad = {
      natural_scroll = true,
      clickfinger_behavior = true,
      disable_while_typing = true,
      -- Control the speed of your scrolling
      scroll_factor = 0.4,
      drag_lock = 2,
    },
  },
})

-- ================================
-- GESTURES
-- ================================

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "down", mods = "ALT", action = "close" })
hl.gesture({ fingers = 3, direction = "up", mods = "SUPER", scale = 1.5, action = "fullscreen" })

-- ================================
-- WINDOW RULES
-- ================================

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/ for more
hl.window_rule({
  name = "windowrule-1",
  match = { class = ".*" },
  suppress_event = "maximize",
  opacity = "1 1",
})

-- satty (print screen editor) should have room.
hl.window_rule({
  name = "windowrule-2",
  match = { title = "(satty)" },
  size = { "(monitor_w*0.8)", "(monitor_h*0.8)" },
  center = true,
})

-- Force chromium into a tile to deal with --app bug
hl.window_rule({
  name = "windowrule-3",
  match = { class = "^(Chromium)$" },
  tile = true,
})

-- Floating windows
hl.window_rule({
  name = "windowrule-4",
  match = { tag = "floating-window" },
  float = true,
  center = true,
  size = { 800, 600 },
})

hl.window_rule({
  name = "windowrule-5",
  match = { class = "(blueberry.py|Impala|Wiremix|org.gnome.NautilusPreviewer|com.gabm.satty|TUI.float)" },
  tag = "+floating-window",
})

hl.window_rule({
  name = "windowrule-6",
  match = {
    class = "(xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus)",
    title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files)",
  },
  tag = "+floating-window",
})

-- No transparency on media windows
hl.window_rule({
  name = "windowrule-7",
  match = { class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$" },
  opacity = "1 1",
})

-- Float Steam, fullscreen RetroArch
hl.window_rule({
  name = "windowrule-8",
  match = { class = "^(steam)$" },
  float = true,
})

hl.window_rule({
  name = "windowrule-9",
  match = { class = "^(com.libretro.RetroArch)$" },
  fullscreen = true,
})

-- Just dash of opacity
hl.window_rule({
  name = "windowrule-10",
  match = { class = "^(Chromium|chromium|google-chrome|google-chrome-unstable)$" },
  opacity = "1 0.97",
})

hl.window_rule({
  name = "windowrule-11",
  match = { title = ".*- YouTube$" },
  opacity = "1 1",
})

hl.window_rule({
  name = "windowrule-12",
  match = { title = ".*Netflix$" },
  opacity = "1 1",
})

hl.window_rule({
  name = "windowrule-13",
  match = { title = ".*Prime.*$" },
  opacity = "1 1",
})

hl.window_rule({
  name = "windowrule-14",
  match = { class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv)$" },
  opacity = "1 1",
})

hl.window_rule({
  name = "windowrule-15",
  match = { class = "^(com.libretro.RetroArch|steam)$" },
  opacity = "1 1",
})

-- Large TUI floating windows (btop, etc.)
hl.window_rule({
  name = "windowrule-16",
  match = { class = "^(TUI\\.float\\.large)$" },
  float = true,
  center = true,
  size = { 1400, 900 },
})

-- Fix some dragging issues with XWayland
hl.window_rule({
  name = "windowrule-17",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

-- Scroll faster in the terminal
hl.window_rule({
  name = "windowrule-18",
  match = { class = "Alacritty" },
  scroll_touchpad = 1.5,
})

-- Proper background blur for wofi
hl.layer_rule({
  name = "layerrule-1",
  match = { namespace = "wofi" },
  blur = true,
})

-- ================================
-- WORKSPACE AUTO-START
-- ================================

hl.workspace_rule({ workspace = "1", on_created_empty = "ghostty" })
hl.workspace_rule({ workspace = "2", on_created_empty = "chromium" })
hl.workspace_rule({ workspace = "4", on_created_empty = "fastmail" })
hl.workspace_rule({ workspace = "5", on_created_empty = "signal-desktop" })

-- ================================
-- APPLICATION VARIABLES
-- ================================

local terminal = "ghostty"
local browser = "chromium --new-window --ozone-platform=wayland"
local webapp = browser .. " --app"

-- ================================
-- KEYBINDINGS - APPLICATIONS
-- ================================

hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + E", hl.dsp.exec_cmd("nautilus --new-window"))
hl.bind("SUPER + B", hl.dsp.exec_cmd(browser))
hl.bind("SUPER + M", hl.dsp.exec_cmd("spotify"))
hl.bind("SUPER + N", hl.dsp.exec_cmd(terminal .. " -e nvim"))
hl.bind("SUPER + T", hl.dsp.exec_cmd("ghostty --command=~/.config/tmux/btop-tmux.sh --class=TUI.float.large"))

hl.bind("SUPER + D", hl.dsp.exec_cmd(terminal .. " -e lazydocker"))
hl.bind("SUPER + G", hl.dsp.exec_cmd("signal-desktop"))
hl.bind("SUPER + slash", hl.dsp.exec_cmd("1password"))

hl.bind("SUPER + X", hl.dsp.exec_cmd(webapp .. '="https://claude.ai"'))

-- ================================
-- KEYBINDINGS - MEDIA CONTROLS
-- ================================

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- ================================
-- KEYBINDINGS - WINDOW TILING
-- ================================

hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Close window
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + W", hl.dsp.send_shortcut({ mods = "CTRL", key = "W" }))

-- Control tiling
hl.bind("SUPER + J", hl.dsp.layout("togglesplit")) -- dwindle
hl.bind("SUPER + P", hl.dsp.window.pseudo()) -- dwindle

-- Move focus with mainMod + arrow keys
hl.bind("SUPER + left",  hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up",    hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with ALT + [0-9] (keycodes 10-19)
-- Move active window to a workspace with ALT + SHIFT + [0-9]
for i = 1, 10 do
  hl.bind("ALT + code:" .. (i + 9),         hl.dsp.focus({ workspace = i }))
  hl.bind("ALT + SHIFT + code:" .. (i + 9), hl.dsp.window.move({ workspace = i }))
end

-- Swap active window with the one next to it with mainMod + SHIFT + arrow keys
hl.bind("SUPER + SHIFT + left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind("SUPER + SHIFT + up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind("SUPER + SHIFT + down",  hl.dsp.window.swap({ direction = "down" }))
hl.bind("SUPER + SHIFT + X",     hl.dsp.window.move({ monitor = "+1" }))

-- Resize active window
hl.bind("ALT + minus",         hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.bind("ALT + equal",         hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
hl.bind("ALT + SHIFT + minus", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
hl.bind("ALT + SHIFT + equal", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ================================
-- KEYBINDINGS - UTILITIES
-- ================================

-- Trackpad toggle
hl.bind("XF86TouchpadToggle", hl.dsp.exec_cmd("~/.config/hypr/scripts/trackpad-toggle.sh"), { locked = true })
hl.bind("SUPER + period", hl.dsp.exec_cmd("~/.config/hypr/scripts/trackpad-toggle.sh"))

-- Launching
hl.bind("SUPER + space", hl.dsp.exec_cmd('pkill wofi || wofi --show drun --style="$HOME/.config/farv/current/wofi-search.css"'))

-- Clipboard history
hl.bind("SUPER + v", hl.dsp.exec_cmd("~/.local/bin/clipboard-manager"))

-- Aesthetics
hl.bind("SUPER + SHIFT + space", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))

-- Notifications
hl.bind("SUPER + comma", hl.dsp.exec_cmd("swaync-client --toggle-panel"))

-- Screenshots
-- Note: both SUPER + Print binds below fire on the same key (top to bottom),
-- same as the original config's SUPER, Print / SUPER, PRINT pair.
hl.bind("Print", hl.dsp.exec_cmd("grimblast save area - | satty -f -"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd("grimblast save area - | satty -f - --copy-command /home/tmadsen/.local/bin/screenshot-base64-html"))

-- Color picker
hl.bind("SUPER + Print", hl.dsp.exec_cmd("hyprpicker -a"))

-- Smiley menu
hl.bind("CTRL + ALT + SUPER + S", hl.dsp.exec_cmd("~/.local/bin/smiley-menu"))

-- Power menu
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("~/.config/hypr/scripts/power-menu.sh"), { locked = true })

-- ================================
-- THEME OVERRIDES (farv)
-- ================================

-- The farv theme system ships hyprlang-format theme files, so instead of
-- source-ing them, parse the active border gradient out of the current theme.
-- Falls back to the colors set above if the file is missing or unparseable.
local ok, err = pcall(function()
  local path = os.getenv("HOME") .. "/.config/farv/current/hyprland.conf"
  for line in io.lines(path) do
    local value = line:match("col%.active_border%s*=%s*(.+)")
    if value then
      local colors = {}
      for color in value:gmatch("rgba?%(%x+%)") do
        table.insert(colors, color)
      end
      local angle = tonumber(value:match("(%-?%d+)deg"))
      if #colors > 0 then
        hl.config({
          general = {
            col = {
              active_border = { colors = colors, angle = angle or 0 },
            },
          },
        })
      end
      break
    end
  end
end)
if not ok then
  print("farv theme override not applied: " .. tostring(err))
end
