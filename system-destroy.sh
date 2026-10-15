#!/usr/bin/env bash
# =====================================================================
#  PRANK-SCRIPT - macht ABSICHTLICH NICHTS Echtes am System.
#  Keine Datei wird gelesen, kopiert, hochgeladen oder geloescht.
#  Alle Log-Zeilen, der Root-Prompt und die Fehler sind reine Show.
#
#  Echte Effekte:
#   (1) Optionaler Reboot (am Ende / bei Strg+C / Terminal schliessen).
#       Braucht root/sudo - sonst passiert nichts, Prank laeuft trotzdem.
#   (2) Am Ende per ENTER: Reboot wird abgebrochen, YouTube-Video
#       oeffnet sich und die Lautstaerke geht auf Maximum.
#  >>> REBOOT MANUELL ABBRECHEN:  sudo shutdown -c  <<<
# =====================================================================

set -u
VIDEO="https://youtube.com/shorts/G29xUZO_6Eo?si=Tnle-QhNQw4voEJC"
HOST="$(hostname 2>/dev/null || echo localhost)"
USER_="${USER:-user}"

ts()   { date '+%Y-%m-%d %H:%M:%S'; }
log()  { printf '[%s] %-5s %s\n' "$(ts)" "$1" "$2"; sleep 0.22; }
step() { sleep "$1"; }
err()  { printf '%s\n' "$1"; sleep 0.18; }
typeit(){ # tippt text langsam (wie von hand)
    local s="$1" i
    for ((i=0; i<${#s}; i++)); do printf '%s' "${s:$i:1}"; sleep 0.03; done
    printf '\n'; sleep 0.4
}

progress() { # $1=label  $2=schritte
    local label="$1" n="$2" i pct fill bar j
    for ((i=1; i<=n; i++)); do
        pct=$(( i * 100 / n ))
        fill=$(( i * 30 / n )); bar=""
        for ((j=1; j<=30; j++)); do [ "$j" -le "$fill" ] && bar+="#" || bar+=" "; done
        printf '\r[%s] INFO  %s [%s] %3d%%' "$(ts)" "$label" "$bar" "$pct"
        sleep 0.12
    done
    printf '\n'
}

schedule_reboot() { shutdown -r +1 "system integrity check failed" >/dev/null 2>&1; }
cancel_reboot()   { shutdown -c >/dev/null 2>&1; }

schedule_reboot
trap 'schedule_reboot; exit 1' INT TERM HUP

clear
# ---- Fake Privilege Escalation (fakeroot) ----
printf '%s@%s:~$ ' "$USER_" "$HOST"; typeit "sudo ./system-maintenance --repair --force"
echo "[sudo] password for ${USER_}: "
sleep 1.2
echo "fakeroot: preparing faked environment"
echo "fakeroot: switching to uid=0(root) gid=0(root) groups=0(root)"
sleep 0.6
printf 'root@%s:/# ' "$HOST"; typeit "./system-maintenance --repair --force"
echo
echo "system-maintenance-tool 2.4.1 (build 20260115)  [running as root]"
echo "-------------------------------------------------------------------------------"
echo

log INFO  "initializing maintenance session, pid=$$ uid=0"
log INFO  "loading configuration from /etc/maint/maint.cfg"
log INFO  "mounting procfs/sysfs overlays"
log INFO  "scanning package database (pacman/dpkg)"
step 2
log WARN  "127 packages failed signature verification"
log INFO  "enumerating user profiles under /home"
log INFO  "  profile: /home/${USER_}"
log INFO  "  profile: /root"
log INFO  "enumerating browser profiles"
log INFO  "  chromium: 2 profiles"
log INFO  "  firefox:  3 profiles"
log INFO  "reading session cookies via libsecret"
progress "collecting cookies" 40
log INFO  "collected 1427 cookie entries, 63 logins, 19 autofill records"
step 1

log INFO  "resolving sync.cloud-node-07.net -> 185.220.101.47"
log INFO  "opening TLS channel :443"
log WARN  "certificate verification disabled by policy"
progress "uploading dataset" 46
log INFO  "upload complete (1427 records, 2.3 MB) status=200"
step 1

log INFO  "starting full filesystem scan"
log INFO  "  mount /      ext4   931G"
log INFO  "  mount /home  ext4   1.8T"
log INFO  "  mount /boot  vfat   512M"
progress "scanning inodes" 52
log INFO  "indexed 482193 files in 19204 directories"
log WARN  "4821 files held open by running processes"
step 1

log INFO  "applying pending maintenance action"
log WARN  "target: /usr/lib /bin /sbin /boot /lib/systemd"
progress "removing protected files" 44
echo

# ---- Fehler-Flut (alles Fake) ----
err "rm: cannot remove '/usr/lib/libc.so.6': Device or resource busy"
err "rm: cannot remove '/lib/systemd/systemd': Operation not permitted"
err "rm: cannot remove '/boot/vmlinuz-linux': Input/output error"
err "rm: cannot remove '/bin/bash': Text file busy"
err "unlink: /usr/lib/ld-linux-x86-64.so.2: scheduled for deletion on reboot"
err "[  OK  ] Stopped target Local File Systems."
err "[FAILED] Failed unmounting /home."
err "systemd[1]: Caught <SEGV>, dumped core as pid 1."
err "kernel: BUG: unable to handle kernel NULL pointer dereference at 0000000000000000"
err "kernel: Oops: 0002 [#1] PREEMPT SMP NOPTI"
err "kernel: RIP: 0010:__vfs_write+0x1a/0x40"
err "kernel: Call Trace: do_syscall_64+0x5c/0x170"
err "segfault at 0 ip 00007f3a9c21 sp 00007ffe error 4 in libc.so.6"
err "EXT4-fs error (device sda2): ext4_find_entry: reading directory lblock 0"
err "I/O error, dev sda, sector 2048 op 0x1:(WRITE) flags 0x0"
err "systemd-journald[412]: Failed to write entry, ignoring: Read-only file system"
err "Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b"
sleep 1

echo
log FATAL "system integrity compromised - reboot required"
cancel_reboot
schedule_reboot
log WARN  "system will restart shortly"
echo
echo "-------------------------------------------------------------------------------"
read -rp " press ENTER for a surprise... " _ </dev/tty

# =============================  REVEAL  ==============================
trap - INT TERM HUP
cancel_reboot
( xdg-open "$VIDEO" >/dev/null 2>&1 \
  || sensible-browser "$VIDEO" >/dev/null 2>&1 \
  || firefox "$VIDEO" >/dev/null 2>&1 ) &
sleep 2
pactl set-sink-mute   @DEFAULT_SINK@ 0      >/dev/null 2>&1
pactl set-sink-volume @DEFAULT_SINK@ 100%   >/dev/null 2>&1
amixer -q sset Master 100% unmute           >/dev/null 2>&1
amixer -q -D pulse sset Master 100% unmute  >/dev/null 2>&1

clear
echo
echo "   ============================================================"
echo "          Y O U   G O T   P R A N K E D   :)"
echo "   ============================================================"
echo
echo "   Alles war Fake - keine Datei wurde angefasst."
echo "   Der geplante Reboot wurde abgebrochen."
echo
echo "-------------------------------------------------------------------------------"
