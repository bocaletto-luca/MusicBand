# StudioBand
#### Author: Bocaletto Luca

StudioBand is a professional, terminal-based application manager for audio and music production on Debian/Ubuntu. With a clean ASCII UI powered by `whiptail`, you can install, remove (with “keep config” or full purge), inspect, and launch your favorite DAWs, synths, players and CLI utilities—all from one script.

## Table of Contents

- [Features](#features)  
- [Requirements](#requirements)  
- [Installation](#installation)  
- [Usage](#usage)  
- [Adding Custom Apps](#adding-custom-apps)  
- [Customization](#customization)  
- [Contributing](#contributing)  
- [License](#license)  

---

## Features

- Pre-mapped catalog of popular audio/music apps (DAWs, synths, players, JACK/PipeWire tools)  
- Instant status overview: installed vs not installed  
- One-step install or remove; choose between `remove` (preserve config) or `purge` (wipe config)  
- Launch multiple installed apps in parallel from a checklist menu  
- Extendable “custom apps” system—add any APT package + launch command  
- Persist settings and custom entries under `~/.studioband/` for future sessions  

---

## Requirements

- Debian or Ubuntu (and derivatives)  
- Bash 4.x or newer  
- `whiptail` (install via `sudo apt-get install -y whiptail`)  
- Sudo privileges  

---

## Installation

```bash
# 1. Clone this repository
git clone https://github.com/bocaletto-luca/StudioBand.git
cd StudioBand

# 2. Make the script executable
chmod +x StudioBand.sh

# 3. Ensure whiptail is installed
sudo apt-get update
sudo apt-get install -y whiptail

# 4. Launch StudioBand
./StudioBand.sh
```

---

## Usage

When you run `./StudioBand.sh`, a main menu appears with:

1. **Install / Remove applications**  
   - Check apps to install (OFF) or remove (ON)  
   - After removal selection, choose `remove` (keep config) or `purge` (delete config)  

2. **Show application status**  
   - See a ✔/✖ list of installed vs not installed  

3. **Launch applications**  
   - Select one or more installed apps to start in background  

4. **Add custom app**  
   - Define ID, descriptive name, APT package and launch command  
   - Saved to `~/.studioband/apps.custom` and loaded on next run  

5. **Info / Help**  
   - Version info and config file location  

6. **Exit**  

---

## Adding Custom Apps

1. Choose **Add custom app** from the main menu.  
2. Enter a unique ID (e.g. `mydrum`), a descriptive name, the APT package name, and the launch command.  
3. StudioBand appends your entry to `~/.studioband/apps.custom` and reloads—your new app appears immediately in all menus.

---

## Customization

- Built-in apps are defined in the arrays `APP_NAME` and `APP_CMD` at the top of `StudioBand.sh`.  
- Custom entries live in `~/.studioband/apps.custom`.  
- Back up or restore your entire setup by copying `~/.studioband/`.

---

## Contributing

I welcome improvements, bug fixes and new app definitions! To contribute:

1. Fork this repo  
2. Create a feature branch (`git checkout -b feature-name`)  
3. Commit your changes and push (`git push origin feature-name`)  
4. Open a Pull Request describing your enhancements  

I’ll review and merge as soon as possible. Thanks for helping make StudioBand better!

---

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).  
© 2025 Luca Bocaletto ([@bocaletto-luca](https://github.com/bocaletto-luca))  
