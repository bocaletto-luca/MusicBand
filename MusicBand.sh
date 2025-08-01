#!/usr/bin/env bash
#
# StudioBand.sh v1.0.0
# Terminal-based manager for audio & music-production applications
# Compatible with Debian/Ubuntu – clean ASCII UI (whiptail)
# Language: English
# Author: Luca Bocaletto
# License: GPLv3
# Date: 2025-08-02
#

set -euo pipefail
IFS=$'\n\t'

# Force ASCII borders in whiptail (disable Unicode ACS)
export NCURSES_NO_UTF8_ACS=1

# Script version
readonly VERSION="1.0.0"

# Configuration directory & custom apps file
readonly CONFIG_DIR="$HOME/.studioband"
readonly CUSTOM_APPS_FILE="$CONFIG_DIR/apps.custom"

# Ensure whiptail is installed
if ! command -v whiptail >/dev/null 2>&1; then
  echo "Error: whiptail is not installed."
  echo "Install it with: sudo apt-get update && sudo apt-get install -y whiptail"
  exit 1
fi

# Create config directory if absent
mkdir -p "$CONFIG_DIR"

# -------------------------------------------------------------------
# 1) Built-in application catalog
# -------------------------------------------------------------------
declare -A APP_NAME=(
  [ardour]="Ardour – Professional DAW"
  [lmms]="LMMS – Pattern-based music production"
  [qtractor]="Qtractor – JACK-centric DAW"
  [rosegarden]="Rosegarden – MIDI & notation"
  [musescore]="MuseScore – Music notation"
  [hydrogen]="Hydrogen – Advanced drum machine"
  [carla]="Carla – Audio plugin host (VST/LV2)"
  [sooperlooper]="SooperLooper – Live looping"
  [audacity]="Audacity – Audio editor"
  [mixxx]="Mixxx – DJ mixing software"
  [jackd2]="JACK2 – Low-latency audio server"
  [pipewire]="PipeWire – Modern audio server"
  [pulseaudio]="PulseAudio – Sound server"
  [qjackctl]="QjackCtl – GUI for JACK"
  [patchage]="Patchage – LV2/JACK patch bay"
  [cadence]="Cadence – KXStudio toolsuite"
  [fluidsynth]="FluidSynth – SoundFont synthesizer"
  [qsynth]="Qsynth – GUI for FluidSynth"
  [ffmpeg]="FFmpeg – Multimedia framework"
  [sox]="SoX – Sound processing toolkit"
  [ecasound]="Ecasound – Multitrack audio recorder"
  [alsa-utils]="ALSA Utils – Mixer & MIDI tools"
)

declare -A APP_CMD=(
  [ardour]="ardour"
  [lmms]="lmms"
  [qtractor]="qtractor"
  [rosegarden]="rosegarden"
  [musescore]="musescore"
  [hydrogen]="hydrogen"
  [carla]="carla"
  [sooperlooper]="sooperlooper"
  [audacity]="audacity"
  [mixxx]="mixxx"
  [jackd2]="jackd"
  [pipewire]="pipewire"
  [pulseaudio]="pulseaudio"
  [qjackctl]="qjackctl"
  [patchage]="patchage"
  [cadence]="cadence"
  [fluidsynth]="fluidsynth"
  [qsynth]="qsynth"
  [ffmpeg]="ffmpeg"
  [sox]="sox"
  [ecasound]="ecasound"
  [alsa-utils]="alsamixer"
)

# -------------------------------------------------------------------
# 2) Load user-defined custom apps
# -------------------------------------------------------------------
if [[ -f "$CUSTOM_APPS_FILE" ]]; then
  while IFS='|' read -r id name pkg cmd; do
    [[ -z "$id" || -z "$pkg" ]] && continue
    APP_NAME[$id]="$name"
    APP_CMD[$id]="$cmd"
  done <"$CUSTOM_APPS_FILE"
fi

# -------------------------------------------------------------------
# 3) Utility functions
# -------------------------------------------------------------------

# Check if APT package is installed
is_installed() {
  dpkg-query -W -f='${Status}' "$1" 2>/dev/null \
    | grep -q "install ok installed"
}

# Install packages (update cache once)
install_pkgs() {
  sudo apt-get update -qq
  sudo apt-get install -y "$@"
}

# Remove packages (keep configuration)
remove_pkgs() {
  sudo apt-get remove -y "$@"
}

# Purge packages (delete configuration)
purge_pkgs() {
  sudo apt-get purge -y "$@"
}

# -------------------------------------------------------------------
# 4) Whiptail menu definitions
# -------------------------------------------------------------------

# Main menu
main_menu() {
  whiptail --clear --title "StudioBand v$VERSION" \
    --menu "Select an action:" 16 60 6 \
    1 "Install / Remove Applications" \
    2 "Show Application Status" \
    3 "Launch Applications" \
    4 "Add Custom Application" \
    5 "Info / Help" \
    6 "Exit" 3>&1 1>&2 2>&3
}

# Install / Remove checklist
manage_menu() {
  local items=()
  for id in "${!APP_NAME[@]}"; do
    if is_installed "$id"; then
      items+=("$id" "${APP_NAME[$id]}" "ON")
    else
      items+=("$id" "${APP_NAME[$id]}" "OFF")
    fi
  done
  whiptail --clear --title "Install / Remove" \
    --checklist "OFF = install, ON = remove" 20 70 15 \
    "${items[@]}" 3>&1 1>&2 2>&3
}

# Choose removal mode: remove or purge
removal_mode_menu() {
  whiptail --clear --title "Removal Mode" \
    --menu "1 = remove (keep config) | 2 = purge (delete config)" \
    10 50 2 \
    1 "remove" \
    2 "purge" 3>&1 1>&2 2>&3
}

# Show installed vs not installed
status_menu() {
  local output=""
  for id in "${!APP_NAME[@]}"; do
    if is_installed "$id"; then
      output+="✔ ${APP_NAME[$id]}\n"
    else
      output+="✖ ${APP_NAME[$id]}\n"
    fi
  done
  whiptail --clear --title "Application Status" \
    --msgbox "$output" 20 60
}

# Launch one or more installed apps
launch_menu() {
  local items=()
  for id in "${!APP_NAME[@]}"; do
    is_installed "$id" && items+=("$id" "${APP_NAME[$id]}" "OFF")
  done

  local selected
  selected=$(whiptail --clear --title "Launch Applications" \
    --checklist "Select apps to launch:" \
    20 70 15 \
    "${items[@]}" 3>&1 1>&2 2>&3) || return

  for id in $selected; do
    setsid "${APP_CMD[$id]}" &>/dev/null &
  done
}

# Add a custom application
add_custom_app() {
  local id name pkg cmd
  id=$(whiptail --inputbox "Enter unique ID (e.g. mydrum):" 8 50 3>&1 1>&2 2>&3)    || return
  name=$(whiptail --inputbox "Enter descriptive name:" 8 50 3>&1 1>&2 2>&3)         || return
  pkg=$(whiptail --inputbox "Enter APT package name:" 8 50 3>&1 1>&2 2>&3)          || return
  cmd=$(whiptail --inputbox "Enter launch command:" 8 50 3>&1 1>&2 2>&3)             || return

  echo "$id|$name|$pkg|$cmd" >>"$CUSTOM_APPS_FILE"
  whiptail --msgbox "Custom application added successfully!" 8 50
  exec "$0"  # Reload script to include new entry
}

# Info / Help screen
help_menu() {
  whiptail --clear --title "Info / Help" --msgbox "\
StudioBand v$VERSION

Manage your DAWs, synths, players & audio utilities:
 • Install / Remove (remove or purge)
 • Show status of all apps
 • Launch multiple apps from menu
 • Add custom applications

Config directory: $CONFIG_DIR
Custom list file: $CUSTOM_APPS_FILE

© 2025 Luca Bocaletto
Licensed under GPLv3" 16 60
}

# -------------------------------------------------------------------
# 5) Main program loop
# -------------------------------------------------------------------
while true; do
  case "$(main_menu)" in
    1)
      mapfile -t selection < <(manage_menu)
      to_install=() to_remove=()
      for id in "${selection[@]}"; do
        if is_installed "$id"; then
          to_remove+=("$id")
        else
          to_install+=("$id")
        fi
      done

      if ((${#to_remove[@]})); then
        mode=$(removal_mode_menu)
        if [[ "$mode" == "2" ]]; then
          purge_pkgs "${to_remove[@]}"
        else
          remove_pkgs "${to_remove[@]}"
        fi
      fi

      if ((${#to_install[@]})); then
        install_pkgs "${to_install[@]}"
      fi
      ;;
    2) status_menu    ;;
    3) launch_menu    ;;
    4) add_custom_app ;;
    5) help_menu      ;;
    6) break          ;;
    *) break          ;;
  esac
done

clear
echo "Thank you for using StudioBand v$VERSION. Happy music making!"
