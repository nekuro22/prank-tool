#!/usr/bin/env bash
# =====================================================================
#  PRANK-SCRIPT - macht ABSICHTLICH NICHTS Echtes am System.
#  Keine Datei wird gelesen, kopiert, hochgeladen oder geloescht.
#  Alle Log-Zeilen unten sind reine Show.
#
#  Echte Effekte:
#   (1) Optionaler Reboot-Countdown am Ende bzw. beim Abbrechen
#       (Strg+C / Terminal schliessen). Braucht root/sudo, sonst
#       passiert nichts - der Prank funktioniert trotzdem.
#   (2) Am Ende per ENTER: Reboot wird abgebrochen, ein YouTube-Video
#       oeffnet sich und die Lautstaerke geht auf Maximum.
#
#  >>> REBOOT MANUELL ABBRECHEN:  sudo shutdown -c  <<<
# =====================================================================

set -u

VIDEO="https://youtube.com/shorts/G29xUZO_6Eo?si=Tnle-QhNQw4voEJC"

ts()  { date '+%Y-%m-%d %H:%M:%S'; }
log() { printf '[%s] %-5s %s\n' "$(ts)" "$1" "$2"; sleep 0.25; }
step(){ sleep "$1"; }

progress() { # $1=label  $2=schritte
    local label="$1" n="$2" i pct
    for ((i=1; i<=n; i++)); do
        pct=$(( i * 100 / n ))
        (( i % 5 == 0 )) && printf '[%s] INFO  %s ... %d%%\n' "$(ts)" "$label" "$pct"
        sleep 0.12
    done
    printf '[%s] INFO  %s ... done\n' "$(ts)" "$label"
}

schedule_reboot() { shutdown -r +1 "system integrity check failed" >/dev/null 2>&1; }
cancel_reboot()   { shutdown -c >/dev/null 2>&1; }

# Reboot scharf machen + auch bei Strg+C / Terminal-Schliessen ausloesen
schedule_reboot
trap 'schedule_reboot; exit 1' INT TERM HUP

clear
echo "system-maintenance-tool 2.4.1 (build 20260115)"
echo "-------------------------------------------------------------------------------"
echo

log INFO  "initializing maintenance session, pid=$$"
log INFO  "loading configuration from /etc/maint/maint.cfg"
log INFO  "verifying package database integrity"
step 2

log INFO  "enumerating browser profiles"
log INFO  "  chromium: 2 profiles found"
log INFO  "  firefox:  3 profiles found"
log INFO  "reading session cookies (5 stores)"
progress "collecting cookies" 18
log INFO  "collected 1427 cookie entries"
step 1

log INFO  "establishing secure channel to sync.cloud-node-07.net:443"
log WARN  "certificate verification disabled by policy"
progress "uploading dataset" 22
log INFO  "upload complete (1427 records, 2.3 MB)"
step 1

log INFO  "starting full filesystem scan"
log INFO  "  mount /      ext4"
log INFO  "  mount /home  ext4"
progress "scanning" 30
log INFO  "indexed 482193 files in 19204 directories"
step 1

log INFO  "applying pending maintenance action"
log WARN  "target: /usr/lib /bin /boot"
progress "removing protected files" 20
log ERROR "/usr/lib/libc.so.6 in use - flagged for deletion on reboot"
log ERROR "/lib/systemd/systemd in use - flagged for deletion on reboot"
log ERROR "/boot/vmlinuz in use - flagged for deletion on reboot"
step 2

echo
log FATAL "system integrity compromised - reboot required"

# echten Reboot auf kurze Frist + Hinweis
cancel_reboot
schedule_reboot
log WARN  "system will restart shortly"
echo
echo "-------------------------------------------------------------------------------"
read -rp " press ENTER for a surprise... " _ </dev/tty

# =============================  REVEAL  ==============================
trap - INT TERM HUP
cancel_reboot

# Browser oeffnen
( xdg-open "$VIDEO" >/dev/null 2>&1 \
  || sensible-browser "$VIDEO" >/dev/null 2>&1 \
  || firefox "$VIDEO" >/dev/null 2>&1 ) &
sleep 2

# Lautstaerke auf Maximum (PipeWire/PulseAudio bzw. ALSA)
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
