#!/bin/bash
# Hibernation setup for the TUXEDO InfinityBook Pro AMD Gen10. See PLAN.md.
#
# Steps 1 to 5 of the plan (root parts). Idempotent: every step checks before
# it changes anything, so the script can be re-run after a partial failure.
# Step 1 asks for the LUKS passphrase, so run it from a real terminal.
#
# Run as root:  sudo ./setup.sh
set -euo pipefail
REBUILD=${1:-}            # pass --rebuild to force mkinitcpio -P

SWAPFILE=/home/swapfile
SWAPSIZE=32G
IMAGE_SIZE=17179869184            # 16 GiB target for the hibernation image
ROOT_UUID=214b8ef5-f48e-4d88-b611-ead524f19522   # LUKS on nvme0n1p2
HOME_UUID=fa222b43-2ae2-47be-abf1-2da65fc18c9e   # LUKS on nvme0n1p3
ENTRIES=/boot/loader/entries
LINUX_ENTRY=$ENTRIES/2025-09-25_10-55-44_linux.conf
FALLBACK_ENTRY=$ENTRIES/2025-09-25_10-55-44_linux-fallback.conf
LTS_ENTRY=$ENTRIES/linux-lts.conf
OLD_ENTRY=$ENTRIES/linux-old.conf
NEW_HOOKS='HOOKS=(base systemd plymouth autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)'

say()  { printf '\n\033[1m== %s\033[0m\n' "$*"; }
ok()   { printf '   \033[32m✓\033[0m %s\n' "$*"; }
skip() { printf '   \033[2m· %s (already done)\033[0m\n' "$*"; }
die()  { printf '   \033[31m✗ %s\033[0m\n' "$*" >&2; exit 1; }

[ "$(id -u)" = 0 ] || die "run as root"
for f in "$LINUX_ENTRY" "$LTS_ENTRY" /etc/mkinitcpio.conf; do [ -f "$f" ] || die "missing $f"; done
blkid -U "$ROOT_UUID" >/dev/null || die "root LUKS UUID not found"
blkid -U "$HOME_UUID" >/dev/null || die "home LUKS UUID not found"
mountpoint -q /home || die "/home is not a mount point"

# ---------------------------------------------------------------- 1. passphrase on home
say "1. Passphrase on home"
echo "   The initramfs retries the passphrase typed for root on home. Type your ROOT passphrase:"
if cryptsetup open --test-passphrase "/dev/disk/by-uuid/$HOME_UUID"; then
    ok "home accepts the root passphrase (one prompt at boot)"
else
    die "home does not accept it. Add it first:  cryptsetup luksAddKey /dev/disk/by-uuid/$HOME_UUID   (then re-run)"
fi

# ---------------------------------------------------------------- 2. swapfile
say "2. Swapfile"
if [ -f "$SWAPFILE" ]; then
    skip "$SWAPFILE exists ($(du -h "$SWAPFILE" | cut -f1))"
else
    mkswap -U clear --size "$SWAPSIZE" --file "$SWAPFILE" >/dev/null
    ok "created $SWAPFILE ($SWAPSIZE)"
fi
chmod 600 "$SWAPFILE"
if swapon --show=NAME --noheadings | grep -qx "$SWAPFILE"; then
    skip "swap active"
else
    swapon -p 0 "$SWAPFILE"
    ok "swapon"
fi
if grep -qE "^$SWAPFILE[[:space:]]" /etc/fstab; then
    skip "fstab entry"
else
    printf '%s\tnone\tswap\tdefaults,pri=0\t0 0\n' "$SWAPFILE" >> /etc/fstab
    ok "fstab entry"
fi
TMPFILES=/etc/tmpfiles.d/hibernate-image.conf
RULE="w /sys/power/image_size - - - - $IMAGE_SIZE"
if [ -f "$TMPFILES" ] && grep -qxF "$RULE" "$TMPFILES"; then
    skip "image_size rule"
else
    echo "$RULE" > "$TMPFILES"
    ok "image_size rule -> $TMPFILES"
fi
systemd-tmpfiles --create "$TMPFILES"
OFFSET=$(filefrag -v "$SWAPFILE" | awk '$1=="0:" {sub(/\.\./, "", $4); print $4}')
[[ "$OFFSET" =~ ^[0-9]+$ ]] || die "could not read resume_offset from filefrag"
ok "resume_offset=$OFFSET (device $(findmnt -no SOURCE /home))"
[ "$(findmnt -no SOURCE /home)" = /dev/mapper/home ] || die "/home is not /dev/mapper/home"

# ---------------------------------------------------------------- 3. initramfs
say "3. Initramfs -> systemd hooks"
if [ -f "$OLD_ENTRY" ]; then
    skip "rollback entry $OLD_ENTRY"
else
    cp /boot/initramfs-linux.img /boot/initramfs-linux-old.img
    cp /boot/vmlinuz-linux /boot/vmlinuz-linux-old
    {
        echo "# Rollback entry: kernel + initramfs from before the hibernation setup ($(date +%F))."
        echo "# Busybox hooks, cryptdevice= cmdline. Remove once the new setup is trusted."
        echo "title   Arch Linux (linux, old initramfs)"
        echo "linux   /vmlinuz-linux-old"
        echo "initrd  /initramfs-linux-old.img"
        grep '^options' "$LINUX_ENTRY"
    } > "$OLD_ENTRY"
    ok "rollback entry $OLD_ENTRY (+ vmlinuz-linux-old, initramfs-linux-old.img)"
fi
if grep -qxF "$NEW_HOOKS" /etc/mkinitcpio.conf; then
    skip "mkinitcpio HOOKS"
else
    [ -f /etc/mkinitcpio.conf.pre-hibernation ] || cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.pre-hibernation
    sed -i "s|^HOOKS=(.*)|$NEW_HOOKS|" /etc/mkinitcpio.conf
    grep -qxF "$NEW_HOOKS" /etc/mkinitcpio.conf || die "HOOKS edit failed"
    ok "mkinitcpio HOOKS (backup: /etc/mkinitcpio.conf.pre-hibernation)"
    REBUILD=--rebuild
fi
CRYPTTAB=/etc/crypttab
CRYPTTAB_CONTENT="# root and home are unlocked in the initramfs (x-initrd.attach lines are copied
# into the image by the sd-encrypt hook). One prompt: systemd caches the
# passphrase typed for root and retries it on home. home has nofail so a
# failed unlock in the initramfs still boots (resume from hibernation is then
# skipped and home is asked for again here).
root  UUID=$ROOT_UUID  none  luks,x-initrd.attach
home  UUID=$HOME_UUID  none  luks,x-initrd.attach,nofail
# Before 2026-10-06 home was unlocked after boot with a keyfile (slot 1):
# home UUID=$HOME_UUID /etc/cryptsetup-keys.d/home.key luks,key-slot=1"
if [ -f "$CRYPTTAB" ] && [ "$(cat "$CRYPTTAB")" = "$CRYPTTAB_CONTENT" ]; then
    skip "$CRYPTTAB"
else
    [ -f "$CRYPTTAB.pre-hibernation" ] || cp "$CRYPTTAB" "$CRYPTTAB.pre-hibernation"
    echo "$CRYPTTAB_CONTENT" > "$CRYPTTAB"
    ok "$CRYPTTAB (backup: $CRYPTTAB.pre-hibernation)"
    REBUILD=--rebuild
fi
if [ -f /etc/crypttab.initramfs ]; then
    rm /etc/crypttab.initramfs
    ok "removed deprecated /etc/crypttab.initramfs"
    REBUILD=--rebuild
fi
# fallback image: the fallback boot entry has pointed at a never-built image
for preset in /etc/mkinitcpio.d/linux.preset; do
    if grep -q "^PRESETS=('default' 'fallback')" "$preset"; then
        skip "fallback preset"
    else
        sed -i "s|^PRESETS=('default')|PRESETS=('default' 'fallback')|" "$preset"
        grep -q "^fallback_image=" "$preset" || printf '\nfallback_image="/boot/initramfs-linux-fallback.img"\nfallback_options="-S autodetect"\n' >> "$preset"
        ok "fallback preset enabled in $preset"
        REBUILD=--rebuild
    fi
done
if [ "$REBUILD" = --rebuild ]; then
    say "   mkinitcpio -P (linux + linux-lts, a minute or two)"
    LOG=/var/log/mkinitcpio-hibernation.log
    if ! mkinitcpio -P > "$LOG" 2>&1; then
        tail -30 "$LOG" >&2
        die "mkinitcpio failed (full log: $LOG)"
    fi
    grep -E 'Starting build|Image generation|ERROR|WARNING' "$LOG" | sed 's/^/   /'
else
    skip "mkinitcpio -P: inputs unchanged (pass --rebuild to force)"
fi
for img in /boot/initramfs-linux.img /boot/initramfs-linux-lts.img /boot/initramfs-linux-fallback.img; do
    [ -f "$img" ] || die "missing $img after mkinitcpio"
done
for img in /boot/initramfs-linux.img /boot/initramfs-linux-lts.img; do
    files=$(lsinitcpio "$img")
    for need in usr/lib/systemd/systemd-cryptsetup etc/crypttab usr/lib/systemd/systemd-hibernate-resume \
                usr/lib/systemd/system-generators/systemd-hibernate-resume-generator usr/bin/plymouthd; do
        grep -qx "$need" <<< "$files" || die "$need not in $img"
    done
    tmp=$(mktemp -d)
    (cd "$tmp" && lsinitcpio -x --cpio "$img" >/dev/null 2>&1)
    grep -q "^home .*UUID=$HOME_UUID .*x-initrd.attach" "$tmp/etc/crypttab" || { rm -rf "$tmp"; die "home not in the crypttab inside $img"; }
    rm -rf "$tmp"
done
ok "images rebuilt and verified (cryptsetup, crypttab with home, hibernate-resume, plymouth)"

# ---------------------------------------------------------------- 4. cmdline
say "4. Kernel command line"
NEW_OPTIONS="options root=/dev/mapper/root resume=/dev/mapper/home resume_offset=$OFFSET zswap.enabled=0 rw rootfstype=ext4 quiet splash"
for entry in "$LINUX_ENTRY" "$LTS_ENTRY" "$FALLBACK_ENTRY"; do
    [ -f "$entry" ] || { skip "$(basename "$entry") not present"; continue; }
    opts=$NEW_OPTIONS
    [ "$entry" = "$FALLBACK_ENTRY" ] && opts=${opts% quiet splash}
    if grep -qxF "$opts" "$entry"; then
        skip "$(basename "$entry")"
    else
        [ -f "$entry.pre-hibernation" ] || cp "$entry" "$entry.pre-hibernation"
        sed -i "s|^options .*|$opts|" "$entry"
        ok "$(basename "$entry")"
    fi
done
if [ "$(grep '^default' /boot/loader/loader.conf | awk '{print $2}')" = "$(basename "$LINUX_ENTRY")" ]; then
    skip "default entry"
else
    bootctl set-default "$(basename "$LINUX_ENTRY")"
    ok "default entry -> $(basename "$LINUX_ENTRY")"
fi

# ---------------------------------------------------------------- 5. systemd sleep + lid
say "5. systemd sleep.conf / logind"
mkdir -p /etc/systemd/sleep.conf.d /etc/systemd/logind.conf.d
SLEEP_CONF=/etc/systemd/sleep.conf.d/hibernate.conf
SLEEP_CONTENT="[Sleep]
# Fixed delay: the default battery-estimate mode would wait ~40 h at the
# ~0.7 W s2idle draw and never hibernate overnight.
HibernateDelaySec=2h
HibernateOnACPower=no"
if [ -f "$SLEEP_CONF" ] && [ "$(cat "$SLEEP_CONF")" = "$SLEEP_CONTENT" ]; then
    skip "$SLEEP_CONF"
else
    echo "$SLEEP_CONTENT" > "$SLEEP_CONF"
    ok "$SLEEP_CONF"
fi
LID_CONF=/etc/systemd/logind.conf.d/lid.conf
LID_CONTENT="[Login]
HandleLidSwitch=suspend-then-hibernate
HandleLidSwitchExternalPower=suspend-then-hibernate"
if [ -f "$LID_CONF" ] && [ "$(cat "$LID_CONF")" = "$LID_CONTENT" ]; then
    skip "$LID_CONF"
else
    echo "$LID_CONTENT" > "$LID_CONF"
    ok "$LID_CONF (applies after reboot; logind is not restarted here)"
fi

LOGIND_DIR=/etc/systemd/system/systemd-logind.service.d
LOGIND_CONF=$LOGIND_DIR/hibernate-swapfile.conf
LOGIND_CONTENT="[Service]
# systemd-logind ships with ProtectHome=yes, which hides /home from it. Its
# hibernation check opens the swap file listed in /proc/swaps, so with the
# swapfile in /home every Hibernate call failed with 'No such file or
# directory'. Keep /home hidden but expose the swapfile read-only.
ProtectHome=tmpfs
BindReadOnlyPaths=$SWAPFILE"
mkdir -p "$LOGIND_DIR"
if [ -f "$LOGIND_CONF" ] && [ "$(cat "$LOGIND_CONF")" = "$LOGIND_CONTENT" ]; then
    skip "$LOGIND_CONF"
else
    echo "$LOGIND_CONTENT" > "$LOGIND_CONF"
    systemctl daemon-reload
    ok "$LOGIND_CONF (takes effect when logind restarts: reboot)"
fi

say "Done. Next: reboot, expect ONE passphrase prompt, then verify with:"
echo "   swapon --show; cat /sys/power/resume /sys/power/resume_offset; journalctl -b -u systemd-hibernate-resume.service"
echo "   Rollback entry in the boot menu: 'Arch Linux (linux, old initramfs)'."
