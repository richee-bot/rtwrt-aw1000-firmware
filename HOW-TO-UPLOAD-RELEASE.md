# RTWRT — How to upload a new GitHub release

**Repo:** https://github.com/richee-bot/rtwrt-aw1000-firmware  

**Owner account:** `richee-bot`  

This guide is for uploading a new **firmware** (`.bin`) and/or **Android app** (`.apk`) later when you make an update.

No bot needed. Users (or the app later) download from the **Release** links.

---

## Before you start (once)

1. Install **Git** and **GitHub CLI** (`gh`) if needed.
2. Open PowerShell and login:

```powershell
gh auth login
```

Choose: GitHub.com → HTTPS → Login with browser.

3. Check:

```powershell
gh auth status
git --version
```

---

## Important rules

| Do | Don't |
|----|--------|
| Upload big files as **Release assets** | Don't `git add` / commit the `.bin` or huge files into normal commits |
| Use a clear tag: `v4`, `app-1.5` | Don't put secrets (passwords, bot tokens) in release notes if public |
| Test the download URL in a browser | Don't use `t.me/...` links as the app download URL |

---

## A) Upload new **firmware** (sysupgrade.bin)

### A1 — Replace file on the same tag (same URL — easiest)

Keeps this URL working (if filename stays the same):

```text
https://github.com/richee-bot/rtwrt-aw1000-firmware/releases/download/v3/RTWRT-premium-v3-arcadyan_aw1000-sysupgrade.bin
```

```powershell
# Use your real path to the new .bin
gh release upload v3 `
  "C:\Users\Richee\Desktop\RTWRT-v3-TELEGRAM-PACK\RTWRT-premium-v3-arcadyan_aw1000-sysupgrade.bin" `
  --repo richee-bot/rtwrt-aw1000-firmware `
  --clobber
```

- `--clobber` = overwrite existing asset with the **same filename**.
- If your new file has a **different name**, either rename it to match the old name, or create a **new** release (A2).

### A2 — New firmware tag (cleaner history)

```powershell
gh release create v4 `
  "C:\path\to\NEW-sysupgrade.bin" `
  --repo richee-bot/rtwrt-aw1000-firmware `
  --title "RTWRT Firmware v4" `
  --notes "Describe what changed in this firmware"
```

New URL pattern:

```text
https://github.com/richee-bot/rtwrt-aw1000-firmware/releases/download/v4/YOUR-FILENAME.bin
```

If the Android app hardcodes `v3`, either:

- keep using **A1** (same tag + same name), or  
- update the app to the new URL / rebuild app.

### Optional — MD5 of the bin

```powershell
Get-FileHash "C:\path\to\file.bin" -Algorithm MD5
```

Put the hash in the release notes if you want.

---

## B) Upload new **Android app** (APK)

### B1 — Build release APK first

```powershell
cd C:\Users\Richee\Desktop\RTWRT
powershell -ExecutionPolicy Bypass -File scripts\build-apk.ps1 -Release
```

Typical output:

```text
C:\Users\Richee\Desktop\RTWRT\android-project\app\build\outputs\apk\release\app-release.apk
```

(Optional) Copy/rename to something clear, e.g. `RTWRT-richeetayu-v1.5-release.apk`.

### B2 — New app release tag (recommended)

```powershell
gh release create app-1.5 `
  "C:\Users\Richee\Desktop\RTWRT\android-project\app\build\outputs\apk\release\app-release.apk" `
  --repo richee-bot/rtwrt-aw1000-firmware `
  --title "RTWRT Android App v1.5" `
  --notes "Describe what changed in the app"
```

Share with users:

```text
https://github.com/richee-bot/rtwrt-aw1000-firmware/releases/download/app-1.5/app-release.apk
```

(Filename in the URL = exact name of the file you uploaded.)

### B3 — Replace APK on an old app tag

```powershell
gh release upload app-1.3 `
  "C:\path\to\new.apk" `
  --repo richee-bot/rtwrt-aw1000-firmware `
  --clobber
```

Same URL only if the **filename** is unchanged.

---

## C) Upload **both** firmware + app

### Separate releases (clear)

```powershell
# Firmware
gh release create v4 `
  "C:\path\to\sysupgrade.bin" `
  --repo richee-bot/rtwrt-aw1000-firmware `
  --title "Firmware v4" `
  --notes "Router image update"

# App
gh release create app-1.5 `
  "C:\path\to\app-release.apk" `
  --repo richee-bot/rtwrt-aw1000-firmware `
  --title "App v1.5" `
  --notes "App update"
```

### One release with both files

```powershell
gh release create v4 `
  "C:\path\to\sysupgrade.bin" `
  "C:\path\to\app-release.apk" `
  --repo richee-bot/rtwrt-aw1000-firmware `
  --title "RTWRT v4 pack" `
  --notes "Firmware + app"
```

---

## D) Browser method (no CLI)

1. Open: https://github.com/richee-bot/rtwrt-aw1000-firmware/releases  
2. Click **Draft a new release** (or edit an existing release)  
3. **Choose a tag** — create new: `v4` or `app-1.5`  
4. Title + description  
5. **Attach binaries** — drag `.bin` and/or `.apk`  
6. **Publish release**  
7. Click the file name → copy the download link from the browser address bar or “download” button  

To **replace** a file on an existing release: edit the release → delete old asset → upload new one (or use CLI `--clobber`).

---

## After upload — checklist

- [ ] Open the release page in a browser  
- [ ] Click the file — download should start (not an HTML error page)  
- [ ] Copy the **direct** URL and save it / post to Telegram  
- [ ] If app uses a fixed URL: either keep same tag+filename, or update the app  
- [ ] Optional: also copy APK to the router `http://192.168.1.1/rtwrt/app/apk/RTWRT.apk` for LAN users  

---

## Current live links (as of setup)

| What | URL |
|------|-----|
| **Firmware v3** | https://github.com/richee-bot/rtwrt-aw1000-firmware/releases/download/v3/RTWRT-premium-v3-arcadyan_aw1000-sysupgrade.bin |
| **App 1.3** | https://github.com/richee-bot/rtwrt-aw1000-firmware/releases/download/app-1.3/RTWRT-richeetayu-v1.3-release.apk |
| **Releases list** | https://github.com/richee-bot/rtwrt-aw1000-firmware/releases |

Firmware MD5 (v3 original): `c1e8dd5aaf7e6c2dd6ebfabaf612ec47`  
App MD5 (1.3): `7479c713a0f8391b890a6871816cdc17`  

*(Recompute MD5 after every new upload.)*

---

## Quick decision guide

| I updated… | I should… |
|------------|-----------|
| Only router image | Upload new **.bin** (A1 or A2) |
| Only Android app | Build APK → upload **.apk** (B2) |
| Both | Upload both (C) |
| Want same app download URL | Same tag + same filename + `--clobber` |
| Want clean version history | New tags: `v4`, `app-1.5`, … |

---

## Useful commands

```powershell
# List releases
gh release list --repo richee-bot/rtwrt-aw1000-firmware

# View one release
gh release view v3 --repo richee-bot/rtwrt-aw1000-firmware

# Delete a release (careful)
# gh release delete v4 --repo richee-bot/rtwrt-aw1000-firmware --yes
```

---

## Tag naming suggestion

| Tag | Meaning |
|-----|---------|
| `v3`, `v4`, `v5` | Firmware (sysupgrade.bin) |
| `app-1.3`, `app-1.5` | Android APK |

---

*RTWRT · @richeetayu · hihi*  
*Saved for: richee-bot/rtwrt-aw1000-firmware*
