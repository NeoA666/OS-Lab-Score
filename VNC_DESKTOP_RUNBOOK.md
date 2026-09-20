# Private VNC Desktop Runbook (executed & verified)

## Status: DONE — desktop reachable, connection verified

The remote GNOME desktop runs on display `:5` at `admin` (`59.64.94.133`), and the
TigerVNC viewer successfully connected through the SSH tunnel (window title
`admin:5 (zhaoxia) - TigerVNC`). The lock screen renders correctly; no black screen.

VNC password was **reset** (the original was unknown) with `vncpasswd`. The password
is known only to the user and is not recorded anywhere in this project.

## How To Start (local Windows, each time)

Step 1 — open the SSH tunnel. Run in PowerShell and **leave this window open**.
The window blocks with no prompt: that is correct behaviour for `ssh -N`, not a hang.

```powershell
ssh -N -o ExitOnForwardFailure=yes -L 5905:127.0.0.1:5905 -i "$env:USERPROFILE\.ssh\校园网\id_rsa_59.64.94.133" zhaoxia@59.64.94.133
```

Alternative that returns your prompt immediately (tunnel runs hidden):

```powershell
Start-Process ssh -ArgumentList '-N','-o','ExitOnForwardFailure=yes','-L','5905:127.0.0.1:5905','-i',"$env:USERPROFILE\.ssh\校园网\id_rsa_59.64.94.133",'zhaoxia@59.64.94.133' -WindowStyle Hidden
```

Step 2 — open the viewer **in a second** PowerShell window:

```powershell
& "C:\Program Files\TigerVNC\vncviewer.exe" 127.0.0.1:5905
```

Step 3 — enter the VNC password you set with `vncpasswd`. If the GNOME lock screen
appears, press Enter or type the password to unlock the session.

If you ever forget the VNC password, reset it (no root needed, takes effect without
restarting the session):

```powershell
ssh -t -i "$env:USERPROFILE\.ssh\校园网\id_rsa_59.64.94.133" zhaoxia@59.64.94.133 "vncpasswd"
```

Input is not echoed to the screen — type blind. Answer `n` to the view-only prompt
unless you actually want a second, read-only password.

## Verified Environment

- Server: `admin` (login node), user `zhaoxia`.
- OS: **Rocky Linux 8.10 (Green Obsidian)**, kernel `4.18.0-553.el8_10.x86_64`, x86-64.
  Authoritative sources (`hostnamectl`, `/etc/os-release`) both report Rocky Linux.
  Trap: `/etc/redhat-release` is a symlink to `rocky-release` but still contains the stale
  string `CentOS Linux release 8.10 (Green Obsidian)` from a CentOS→Rocky migration.
  Do not trust `cat /etc/redhat-release` on this host; use `hostnamectl`.
- TigerVNC `vncserver` wrapper, Xvnc TigerVNC 1.9.0.
- GNOME session: `/usr/bin/gnome-session`; `/usr/bin/dbus-run-session` present.
- Display in use: `:5`, port `5905`, geometry `1920x1080`, depth `24`.
- Listening only on loopback: `127.0.0.1:5905` and `[::1]:5905`.
- Stale historical `~/.vnc` records for `:3` were left untouched.
- Local SSH key: `C:\Users\111\.ssh\校园网\id_rsa_59.64.94.133`.

## Correction to the original runbook

The original runbook's start command fails on this host:

```bash
vncserver :5 -localhost yes ...   # FAILS: "Unrecognized option: yes"
```

This TigerVNC wrapper takes `localhost` as a **boolean flag**. The working command is:

```bash
vncserver :5 -localhost -geometry 1920x1080 -depth 24
```

Equivalent explicit form: `-localhost=1`. Do not use `-localhost yes`.

## What was done on the server

1. Read-only inspection: display `:5` free, port `5905` free.
2. `~/.vnc/passwd` **already existed** and was deliberately **NOT** overwritten.
3. Created `~/.vnc/xstartup` (mode `700`):

```sh
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-run-session gnome-session
```

4. Started the desktop with the corrected command. Session PID `1438710`.
5. Verified: `vncserver -list` shows `:5`; GNOME Shell runs as
   `/usr/bin/gnome-shell`; the log shows a healthy session start.

## Install a VNC viewer (one time)

No VNC viewer is currently installed on this Windows machine. Pick either:

```powershell
winget install --id TigerVNC.TigerVNC -e
```

or download RealVNC Viewer: https://www.realvnc.com/en/connect/download/viewer/

A viewer that can only be pointed at `127.0.0.1:5905` is sufficient; never point it
at the public address.

## Validation (all confirmed)

- [x] `vncserver -list` reports display `:5` (PID 1438710).
- [x] Listener on `5905` is loopback-only (`127.0.0.1` / `[::1]`), not public.
- [x] GNOME Shell is running inside the `:5` session.
- [x] SSH tunnel forwards correctly — RFB banner `RFB 003.008` read from
      `127.0.0.1:5905` locally through the tunnel.
- [x] No compute workload was started; SLURM remains the path for GPU work.
- [x] **End-to-end desktop view verified**: TigerVNC viewer connected through the tunnel
      and rendered the GNOME lock screen (window title `admin:5 (zhaoxia) - TigerVNC`).
- [x] VNC password reset via `vncpasswd` (16-byte `~/.vnc/passwd`); a view-only password
      was also set at the same time.

## Shutdown

Close the viewer, press `Ctrl+C` in the tunnel window, then:

```bash
vncserver -kill :5
vncserver -list
```

## Troubleshooting

### Black or empty desktop

```bash
tail -100 ~/.vnc/admin:5.log
```

Do not start repeated new sessions before resolving the existing one.

### Local viewer cannot connect

```powershell
Get-NetTCPConnection -LocalPort 5905 -ErrorAction SilentlyContinue
```

Then confirm the remote session with `vncserver -list`. Never bypass the tunnel by
exposing the remote VNC port publicly.

### Restarting the desktop after a shutdown

```bash
vncserver :5 -localhost -geometry 1920x1080 -depth 24
```

### Display or port already in use

Pick another pair consistently: display `:6` → remote port `5906` → tunnel port
`5906` → viewer `127.0.0.1:5906`.

### Password unknown

Reset it with `vncpasswd` (no root required; takes effect immediately without restarting
the session). This **replaces** the existing VNC password:

```powershell
ssh -t -i "$env:USERPROFILE\.ssh\校园网\id_rsa_59.64.94.133" zhaoxia@59.64.94.133 "vncpasswd"
```

The `-t` flag is required, otherwise `vncpasswd` cannot read input. Never send the
password through chat or a script.

## Security Rules (still in force)

1. Always start with `-localhost`.
2. Never put the VNC password or SSH key content in a script or config file.
3. Do not overwrite `~/.vnc/passwd` without explicit user confirmation.
4. Do not touch system services, firewall, nginx, Docker, or other users' sessions.
5. No model training or inference on this desktop — use SLURM.
