# Hibernation on the TUXEDO InfinityBook Pro AMD Gen10

Plan written 2026-10-06. Goal: make `systemctl hibernate` and
`systemctl suspend-then-hibernate` work, so an idle laptop stops at ~0 W
instead of the ~0.7 W that s2idle costs, and show the sleep type in the
battery info.

## Facts the plan rests on

- Kernel 7.2.8 (linux) and 6.18.55 (linux-lts), systemd-boot, three entries
  in /boot/loader/entries. mkinitcpio 42, systemd 262, plymouth 26.
- `/sys/power/state` = freeze mem disk; `/sys/power/disk` = platform;
  `/sys/power/mem_sleep` = s2idle only (no S3). Lockdown off, Secure Boot off.
- Only swap is a 4 GB zram device: nothing on disk can hold a hibernation
  image. RAM is 128 GB, ~4 GB in use.
- Disk: nvme0n1p2 = LUKS (UUID 214b8ef5-f48e-4d88-b611-ead524f19522) -> root,
  ext4, 49 GB, 15 GB free. nvme0n1p3 = LUKS (UUID
  fa222b43-2ae2-47be-abf1-2da65fc18c9e) -> home, ext4, 866 GB, 309 GB free.
  Home is unlocked after boot via /etc/crypttab with a keyfile in slot 1.
- Initramfs uses the busybox hooks: `base udev plymouth autodetect microcode
  modconf kms keyboard keymap consolefont block encrypt filesystems fsck`.
  The `encrypt` hook unlocks exactly one device (cryptdevice= on the cmdline).
- The linux-fallback boot entry points at initramfs-linux-fallback.img, which
  is never built (preset only has 'default'). Pre-existing breakage.

## Decision

Swapfile on /home, and switch the initramfs to the systemd hooks so it can
unlock both LUKS volumes before resume. Rejected: swapfile on root (15 GB
free is too little) and a carved-out swap partition (offline resize from a
live USB, same initramfs change still needed).

Sizing: 32 GB swapfile, kernel image_size target 16 GB. If more than 32 GB is
in use at hibernate time the hibernate fails and the machine stays awake
(or re-suspends, in the suspend-then-hibernate case).

Suspend-then-hibernate gets a fixed HibernateDelaySec=2h. The default
battery-estimate mode would wait ~40 h at 0.7 W and never hibernate overnight.

## Steps

Status markers: [ ] todo, [x] done, [-] skipped (reason noted).

All root parts of steps 1 to 5 are in setup.sh (idempotent, re-runnable,
needs a real terminal for the passphrase prompt).

### 1. Passphrase on home
- [x] `cryptsetup open --test-passphrase` on home with the root passphrase
      (setup.sh does this first and stops if it fails). Passed 2026-10-06. If it fails,
      `cryptsetup luksAddKey` so root and home share a passphrase.
      The systemd initramfs caches the first passphrase and retries it on the
      next volume, so this gives a single prompt at boot.

### 2. Swapfile
- [x] `mkswap -U clear --size 32G --file /home/swapfile` (mode 0600), `swapon`.
- [x] fstab: `/home/swapfile none swap defaults,pri=0 0 0` (zram stays at 100).
- [x] `/etc/tmpfiles.d/hibernate-image.conf`:
      `w /sys/power/image_size - - - - 17179869184`
- [x] Offset: `filefrag -v /home/swapfile | awk '$1=="0:" {print substr($4,1,length($4)-2)}'`
      = 71892992. Recompute if the file is ever recreated or moved.

### 3. Initramfs -> systemd hooks
- [x] Backup: copy /boot/initramfs-linux.img to /boot/initramfs-linux-old.img
      (and vmlinuz-linux-old) and add /boot/loader/entries/linux-old.conf with
      the *current* cmdline. This is the rollback entry.
- [x] /etc/mkinitcpio.conf HOOKS:
      `base systemd plymouth autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck`
      No `resume` hook: the systemd hook ships systemd-hibernate-resume-generator.
- [x] /etc/crypttab (crypttab.initramfs is deprecated in mkinitcpio 42; the
      sd-encrypt hook copies lines carrying x-initrd.attach into the image):
      `root UUID=214b8ef5-f48e-4d88-b611-ead524f19522 none luks,x-initrd.attach`
      `home UUID=fa222b43-2ae2-47be-abf1-2da65fc18c9e none luks,x-initrd.attach,nofail`
      This replaces the keyfile line for home (kept as a comment). The hook
      does not copy keyfiles into the image, and the image sits on the
      unencrypted /boot anyway, so the passphrase is the only option.
      nofail: if home cannot be unlocked in the initramfs the boot still
      continues (no resume) and the real system asks for home again.
- [x] `mkinitcpio -P` (rebuilds linux and linux-lts images). Verified: images
      contain systemd-cryptsetup, the crypttab with home, hibernate-resume.

### 4. Kernel cmdline, all three entries
- [x] Drop `cryptdevice=...`; add `resume=/dev/mapper/home resume_offset=71892992`.
      Result:
      `options root=/dev/mapper/root resume=/dev/mapper/home resume_offset=<N> zswap.enabled=0 rw rootfstype=ext4 quiet splash`
- [x] Fix the dead linux-fallback entry: add 'fallback' to linux.preset so the
      image gets built (done, image exists); fallback cmdline without
      quiet/splash. Done.
- [x] (From earlier today) default -> the linux entry instead of linux-lts.
      bootctl set-default writes the EFI variable LoaderEntryDefault, which
      overrides the `default linux-lts.conf` line still in loader.conf.

### 5. systemd sleep + callers
- [x] /etc/systemd/sleep.conf.d/hibernate.conf:
      `[Sleep]` / `HibernateDelaySec=2h` / `HibernateOnACPower=no`
- [x] /etc/systemd/logind.conf.d/lid.conf: `HandleLidSwitch=hibernate` and
      `HandleLidSwitchExternalPower=hibernate` (was suspend-then-hibernate
      until 2026-10-06 midday; changed after the lid-closed s2idle hang).
      Docked (external display) stays `ignore`. Applied with
      `systemctl reload systemd-logind`.
- [x] /etc/systemd/system/systemd-logind.service.d/hibernate-swapfile.conf:
      `ProtectHome=tmpfs` + `BindReadOnlyPaths=/home/swapfile`. Found during
      testing: logind's unit has ProtectHome=yes, so it cannot open a swapfile
      under /home and every Hibernate/CanHibernate call fails with ENOENT.
      The hibernate services themselves have ProtectHome=no.
- [x] hypr/hypridle.conf: 30 min idle action -> `systemctl suspend-then-hibernate`.
- [x] hypr/scripts/power-menu.sh: Suspend -> suspend-then-hibernate; add Hibernate.

### 6. Sleep type in the battery info
No root hook needed: the user can read the system journal, and systemd-sleep
logs "Performing sleep operation '<op>'" for each phase.
- [x] waybar/battery.py: `mark wake` runs journalctl for systemd-sleep lines
      since the last sleep mark, maps 'suspend' to the active mem_sleep mode
      (s2idle) and keeps the rest, giving "s2idle", "hibernate" or
      "s2idle+hibernate". Stored as a 5th field on the wake event; the Sleep
      section shows it per row. Tested against the live journal: "s2idle".

### 7. s2idle hang workaround (added after the 08:34 lid-close hang)
- [x] /usr/lib/systemd/system-sleep/eno1-down (source: eno1-sleep-hook.sh): on
      `pre`, if eno1 is admin-up, take it down and remember that in /run; on
      `post`, bring it back. The YT6801 NIC's interrupts can keep the SoC
      busy in s2idle (hot, black screen, unwakeable). Installed by setup.sh.
      First attempt went to /etc/systemd/system-sleep, which systemd 262
      ignores (only /usr/lib/systemd/system-sleep is compiled in); the hook
      never ran during the 11:05 and 11:27 sleeps, which resumed fine anyway.
      Verified 11:55-12:14: "eno1 down for suspend" before the sleep,
      networkd Link DOWN; "eno1 up again after suspend" + Link UP after.
- [x] Lid-closed s2idle: 10:36-10:54 and 11:05-11:06 (both
      suspend-then-hibernate, before the hook was active) resumed fine.
- [-] Hibernate handover test skipped: lid now hibernates directly. The
      idle-on-battery action (hypridle, 30 min) and the power menu Suspend
      entry still use suspend-then-hibernate with the 2 h delay.
- [ ] If it hangs again anyway: lid + idle actions -> plain `systemctl hibernate`.

### 8. No double password after hibernate
- [x] hypr/scripts/unlock-after-hibernate.sh in hypridle's after_sleep_cmd:
      if the last "Performing sleep operation" journal line of this boot is
      'hibernate', send hyprlock SIGUSR1 (its built-in unlock signal).
      s2idle resumes stay locked. First version used `loginctl
      unlock-session`, which never reached hyprlock: Hyprland runs as a user
      service (hyprland.service), so hypridle/hyprlock are not in the tty
      session's cgroup and logind's per-session Unlock does not find them.
      Verified live 16:26: lock-session -> hyprlock up -> script -> gone.

### 9. Hibernate hangs too (16:13 and 16:53): find the device
- [ ] Diagnostic sleep hook pm-trace-sleep-hook.sh -> /usr/lib/systemd/
      system-sleep/pm-trace: `echo 1 > /sys/power/pm_trace` before every
      sleep (CONFIG_PM_TRACE_RTC=y). After the next hang + hard reset the
      kernel log of the new boot says "hash matches device ...". Side
      effect: RTC clock garbage after each sleep until timesyncd fixes it.
      Remove with `setup.sh --no-pm-trace` once the culprit is known.
- [ ] Suspect list: Bluetooth (AX210 btusb; the Adv360 Pro keyboard was
      connected at all three hangs, but also at three good hibernates),
      xhci ("invalid context state" warnings after every hibernate resume),
      amdgpu, tuxedo-drivers-dkms modules.

## Testing
Results 2026-10-06: 1 passed (08:16), 2 passed (hibernate 08:27:00, back at
08:28:11 in the same boot, image 5.0 GB written at 4.7 GB/s; battery.py
recorded the wake as "hibernate"). 3 not run yet (optional, see below).

1. Reboot. Expect one passphrase prompt. `swapon --show` lists the file.
   `journalctl -b -u systemd-hibernate-resume` / `cat /sys/power/resume` show
   the home device. Both kernels boot.
2. `systemctl hibernate` with nothing important open. Full power-off, then the
   session comes back after the passphrase.
3. `systemctl suspend-then-hibernate` with HibernateDelaySec temporarily 5min,
   then restore 2h.
4. Rollback: boot the linux-old entry from the systemd-boot menu. Steps 2 to 5
   do not touch data on root or home.

## Log
- 2026-10-06 07:40 Plan saved. battery.py sleep-type recording done (step 6).
  setup.sh written for steps 2-5. Blocked on root: step 1 is interactive
  (needs the passphrase) and sudo has no cached credential in the agent shell.
- 2026-10-06 ~07:55 First setup.sh run (user, terminal): steps 2 and 3 done,
  initramfs rebuilt for both kernels + fallback. Died on a wrong verification
  grep of mine ("sd-encrypt not in the new image"); the image was fine
  (systemd-cryptsetup, crypttab, hibernate-resume, plymouth all present).
  mkinitcpio warned that crypttab.initramfs is deprecated -> moved the
  entries to /etc/crypttab with x-initrd.attach, folded the passphrase test
  into the script, fixed the checks. Steps 4 and 5 still pending; boot
  entries still carry the old cryptdevice= cmdline (bootable either way,
  since the image's crypttab unlocks root).
- 2026-10-06 08:12 Second setup.sh run: passphrase test passed, crypttab
  moved, images rebuilt and verified, cmdlines updated on all three entries,
  default entry -> linux, sleep + lid drop-ins written. Waiting for the
  reboot and the hibernate test. hypridle / power menu still call
  `systemctl suspend` on purpose until hibernate is proven.
- 2026-10-06 08:16 Reboot OK: one passphrase prompt, both volumes unlocked
  in the initramfs, /sys/power/resume = 253:0 (home) offset 71892992,
  resume service ran and found no image (expected).
- 2026-10-06 08:20 `systemctl hibernate` -> "Call to Hibernate failed: No
  such file or directory"; CanHibernate fails the same way. Traced through
  systemd 262 hibernate-util.c: swap_entry_get_resume_config() open()s the
  swap path from /proc/swaps inside logind, and logind has ProtectHome=yes.
  Fix: logind drop-in (above), added to setup.sh. Needs a logind restart;
  a reboot is the safe way (Hyprland holds its seat through logind).
- 2026-10-06 08:28 After the drop-in and a reboot: `systemctl hibernate`
  works, session restored. Switched hypridle and the power menu to
  suspend-then-hibernate, added a Hibernate menu entry. Lid is
  suspend-then-hibernate via logind. Remaining: optional 5 min
  suspend-then-hibernate test; remove the rollback entry (linux-old.conf,
  vmlinuz-linux-old, initramfs-linux-old.img) once the setup is trusted;
  the stale s2idle-regression comment in linux-lts.conf.
- 2026-10-06 08:34 Lid closed -> suspend-then-hibernate -> s2idle entry is
  the last journal line. Machine got hot, could not be woken, forced off at
  ~09:40. Hibernate never ran (alarm was due 10:34; fresh boot found no
  image). Same symptom as the Arch BBS 314219 s2idle hang (YT6801 NIC
  interrupts); intermittent, 13 earlier s2idle cycles on 7.2.8 were fine.
  New factors this time: first sleep after a hibernate/resume in the same
  boot, first lid close via suspend-then-hibernate. Nothing logged, so
  unproven. Added step 7 (eno1 sleep hook) as the known workaround.
- 2026-10-06 ~16:40 Lid close -> hibernate -> LUKS prompt -> desktop, lock
  screen dropped automatically. Confirmed by the user.
- 2026-10-06 16:53 Power menu -> Hibernate: "PM: hibernation: hibernation
  entry" is the last line, machine hot, hard reset at ~16:58, fresh boot
  found no image. Same for the 16:13 lid close (systemd had even written
  the EFI HibernateLocation; kernel never wrote the image). Tally today:
  hibernate 6 attempts / 2 hangs, s2idle ~20 / 1 hang. All hangs stop in
  the device-suspend phase, nothing reaches the journal. Added the pm_trace
  diagnostic hook (step 9).
