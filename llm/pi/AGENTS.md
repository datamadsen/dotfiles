# Global instructions for pi

- The machine runs Arch Linux with Hyprland. Install packages with `yay -S`
  only after asking; never run `sudo` yourself.
- Prefer small, reviewable changes. Show a diff summary when done.
- Do not commit, push or rewrite git history unless asked.
- Models run locally on llama-server with a 32k context window, so read files
  in focused slices (grep first, then read the relevant range) rather than
  whole large files.
