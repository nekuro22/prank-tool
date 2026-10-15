# system-maintenance-tool (Prank)

Ein **harmloser Prank**. Beide Skripte sehen aus wie ein nüchternes System-Tool,
das Cookies sammelt, in die Cloud lädt, das Dateisystem scannt und
System-Dateien löscht – **machen aber absolut nichts** davon. Jede Log-Zeile
ist reine Show.

Am Ende:
- Countdown für einen **echten Reboot** (lässt sich abbrechen, s. u.)
- `press ENTER / any key for a surprise` → Reboot wird **abgebrochen**, ein
  YouTube-Short öffnet sich und die Lautstärke geht auf Maximum
- in der Konsole steht **`YOU GOT PRANKED`**

> Schließt das „Opfer" das Fenster, bevor es die Taste drückt, startet der
> Rechner wirklich neu. Abbrechen:
> - **Linux:** `sudo shutdown -c`
> - **Windows:** `shutdown /a`

---

## Linux

```bash
curl -sL https://raw.githubusercontent.com/<USER>/<REPO>/main/system-destroy.sh | bash
```

Der Reboot-Teil braucht `root`/`sudo` – ohne passiert nichts, der Rest läuft
trotzdem. Für den echten Reboot:

```bash
curl -sL https://raw.githubusercontent.com/<USER>/<REPO>/main/system-destroy.sh | sudo bash
```

## Windows

PowerShell:

```powershell
curl.exe -sL -o "$env:TEMP\maint.bat" https://raw.githubusercontent.com/<USER>/<REPO>/main/SYSTEM_DESTROY.bat; & "$env:TEMP\maint.bat"
```

CMD:

```bat
curl -sL -o "%TEMP%\maint.bat" https://raw.githubusercontent.com/<USER>/<REPO>/main/SYSTEM_DESTROY.bat && "%TEMP%\maint.bat"
```

---

## Anpassen

- Reboot-Frist: in `SYSTEM_DESTROY.bat` die `shutdown /r /t 20`, in
  `system-destroy.sh` die `shutdown -r +1` Zeilen.
- Video: Variable `VIDEO` (Linux) bzw. die `start ""`-Zeile (Windows).

Nur mit Leuten verwenden, die Spaß verstehen. Nicht auf fremden Rechnern.
