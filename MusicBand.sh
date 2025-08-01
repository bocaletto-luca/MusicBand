#!/usr/bin/env bash
#
# StudioBand.sh v0.9.1
# Gestore terminale per applicazioni audio/music production
# Compatibile Debian/Ubuntu – interfaccia ASCII pulita e senza artefatti
#
# Autore: Bocaletto Luca
# License: GPL
# Data: 2025-08-02
#

set -euo pipefail
IFS=$'\n\t'

# forziamo l’uso di bordi ASCII classici (evitiamo glitch con ACS Unicode)
export NCURSES_NO_UTF8_ACS=1

# Versione
readonly VERSION="1.0.1"

# Directory e file di configurazione
readonly CONFIG_DIR="$HOME/.studioband"
readonly CUSTOM_APPS_FILE="$CONFIG_DIR/apps.custom"

# Controllo prerequisiti
if ! command -v whiptail >/dev/null 2>&1; then
  echo "Errore: whiptail non installato."
  echo " Esegui: sudo apt-get update && sudo apt-get install -y whiptail"
  exit 1
fi

# Creazione directory di config se assente
mkdir -p "$CONFIG_DIR"

# -------------------------------------------------------------------
# 1) Definizione delle app 'builtin'
# -------------------------------------------------------------------
declare -A APP_NAME=(
  [lmms]="LMMS (DAW pattern-based)"
  [rosegarden]="Rosegarden (MIDI + partitura)"
  [ardour]="Ardour (DAW professionale)"
  [qtractor]="Qtractor (JACK-centric DAW)"
  [muse]="MusE (sequencer + notazione)"
  [musescore3]="MuseScore (notazione musicale)"
  [tuxguitar]="TuxGuitar (tablature editor)"
  [hydrogen]="Hydrogen (drum machine)"
  [sooperlooper]="SooperLooper (live looper)"
  [giada]="Giada (groovebox live)"
  [audacity]="Audacity (editing audio)"
  [mixxx]="Mixxx (DJ software)"
  [calf-plugins]="Calf Plugins (FX LV2)"
  [carla]="Carla (host VST2/VST3/LV2)"
  [guitarix]="Guitarix (amp simulator)"
  [rakarrack]="Rakarrack (multi-FX chitarra)"
  [jackd2]="JACK2 (audio server realtime)"
  [pipewire]="PipeWire (audio moderno)"
  [pulseaudio]="PulseAudio"
  [qjackctl]="QjackCtl (GUI per JACK)"
  [patchage]="Patchage (patchbay LV2/JACK)"
  [cadence]="Cadence (suite KXStudio)"
  [zynaddsubfx]="ZynAddSubFX (synth avanzato)"
  [yoshimi]="Yoshimi (fork ZynAddSubFX)"
  [fluidsynth]="FluidSynth (soundfont)"
  [qsynth]="Qsynth (GUI FluidSynth)"
  [fluid-soundfont-gm]="SoundFont GM per FluidSynth"
  [helm]="Helm (synth Qt moderno)"
  [vlc]="VLC (player multiformato)"
  [audacious]="Audacious (player leggero)"
  [clementine]="Clementine (music player)"
  [sox]="SoX (CLI audio toolkit)"
  [ffmpeg]="FFmpeg (codec & streaming)"
  [ecasound]="Ecasound (multi-traccia CLI)"
  [alsa-utils]="ALSA Utils (mixer e MIDI CLI)"
  [a2jmidid]="a2jmidid (ALSA⇄JACK MIDI bridge)"
  [aconnectgui]="aconnectgui (MIDI patchbay GUI)"
  [kmidimon]="KmidiMon (MIDI monitor GUI)"
)

declare -A APP_CMD=(
  [lmms]="lmms"
  [rosegarden]="rosegarden"
  [ardour]="ardour"
  [qtractor]="qtractor"
  [muse]="muse"
  [musescore3]="musescore3"
  [tuxguitar]="tuxguitar"
  [hydrogen]="hydrogen"
  [sooperlooper]="sooperlooper"
  [giada]="giada"
  [audacity]="audacity"
  [mixxx]="mixxx"
  [carla]="carla"
  [guitarix]="guitarix"
  [rakarrack]="rakarrack"
  [qjackctl]="qjackctl"
  [patchage]="patchage"
  [cadence]="cadence"
  [zynaddsubfx]="zynaddsubfx"
  [yoshimi]="yoshimi"
  [fluidsynth]="fluidsynth"
  [qsynth]="qsynth"
  [helm]="helm"
  [vlc]="vlc"
  [audacious]="audacious"
  [clementine]="clementine"
  [sox]="sox"
  [ffmpeg]="ffmpeg"
  [ecasound]="ecasound"
  [alsamixer]="alsamixer"
  [a2jmidid]="a2jmidid"
  [aconnectgui]="aconnectgui"
  [kmidimon]="kmidimon"
)

# -------------------------------------------------------------------
# 2) Caricamento delle custom apps utente
# -------------------------------------------------------------------
if [[ -f "$CUSTOM_APPS_FILE" ]]; then
  while IFS='|' read -r id name pkg cmd; do
    [[ -z "$id" || -z "$pkg" ]] && continue
    APP_NAME[$id]="$name"
    APP_CMD[$id]="$cmd"
  done <"$CUSTOM_APPS_FILE"
fi

# -------------------------------------------------------------------
# 3) Funzioni di utilità
# -------------------------------------------------------------------

# Restituisce vero se il pacchetto è installato
is_installed() {
  dpkg-query -W -f='${Status}' "$1" 2>/dev/null \
    | grep -q "install ok installed"
}

# Installazione pacchetti (aggiorna cache una volta)
install_pkgs() {
  sudo apt-get update -qq
  sudo apt-get install -y "$@"
}

# Rimozione mantenendo config
remove_pkgs() {
  sudo apt-get remove -y "$@"
}

# Rimozione con purge (config inclusa)
purge_pkgs() {
  sudo apt-get purge -y "$@"
}

# -------------------------------------------------------------------
# 4) Definizione dei menu whiptail
# -------------------------------------------------------------------

# Menu principale
main_menu() {
  whiptail --clear --title "StudioBand v$VERSION" \
    --menu "Seleziona un’azione:" 15 60 6 \
    1 "Installa / Rimuovi applicazioni" \
    2 "Visualizza stato applicazioni" \
    3 "Lancia applicazioni" \
    4 "Aggiungi custom app" \
    5 "Info / Help" \
    6 "Esci" 3>&1 1>&2 2>&3
}

# Checklist install-remove
manage_menu() {
  local items=()
  for id in "${!APP_NAME[@]}"; do
    if is_installed "$id"; then
      items+=("$id" "${APP_NAME[$id]}" "ON")
    else
      items+=("$id" "${APP_NAME[$id]}" "OFF")
    fi
  done
  whiptail --clear --title "Installa / Rimuovi" \
    --checklist "OFF = Installa, ON = Rimuovi" 20 70 15 \
    "${items[@]}" 3>&1 1>&2 2>&3
}

# Scegli tra remove o purge
removal_mode_menu() {
  whiptail --clear --title "Modalità Rimozione" \
    --menu "Remove: mantieni config  |  Purge: elimina config" \
    10 50 2 \
    1 "remove" \
    2 "purge" 3>&1 1>&2 2>&3
}

# Messaggio stato
status_menu() {
  local out=""
  for id in "${!APP_NAME[@]}"; do
    if is_installed "$id"; then
      out+="✔ ${APP_NAME[$id]}\n"
    else
      out+="✖ ${APP_NAME[$id]}\n"
    fi
  done
  whiptail --clear --title "Stato Applicazioni" \
    --msgbox "$out" 20 60
}

# Checklist per lancio applicazioni
launch_menu() {
  local items=()
  for id in "${!APP_NAME[@]}"; do
    is_installed "$id" && items+=("$id" "${APP_NAME[$id]}" "OFF")
  done
  local sel
  sel=$(whiptail --clear --title "Lancia Applicazioni" \
    --checklist "Seleziona e premi Invio:" 20 70 15 \
    "${items[@]}" 3>&1 1>&2 2>&3) || return

  for id in $sel; do
    setsid "${APP_CMD[$id]}" &>/dev/null &
  done
}

# Aggiungi custom app
add_custom_app() {
  local id name pkg cmd
  id=$(whiptail --inputbox "ID univoco (es. mydrum):" 8 50 3>&1 1>&2 2>&3) || return
  name=$(whiptail --inputbox "Nome descrittivo:" 8 50 3>&1 1>&2 2>&3)    || return
  pkg=$(whiptail --inputbox "Pacchetto apt:" 8 50 3>&1 1>&2 2>&3)       || return
  cmd=$(whiptail --inputbox "Comando di avvio:" 8 50 3>&1 1>&2 2>&3)    || return

  echo "$id|$name|$pkg|$cmd" >>"$CUSTOM_APPS_FILE"
  whiptail --msgbox "Custom app aggiunta!" 8 50
  exec "$0"
}

# Info / Help
help_menu() {
  whiptail --clear --title "Info / Help" --msgbox "\
StudioBand v$VERSION

Gestisci DAW, synth, player e utility:
 • Installa / Rimuovi (keep/purge)
 • Visualizza stato
 • Lancia più app da menu
 • Aggiungi custom apps

Config file: $CUSTOM_APPS_FILE

© 2025 StudioBand Team" 16 60
}

# -------------------------------------------------------------------
# 5) Loop principale
# -------------------------------------------------------------------
while true; do
  case "$(main_menu)" in
    1)
      mapfile -t sel < <(manage_menu)
      to_install=() to_remove=()
      for id in "${sel[@]}"; do
        if is_installed "$id"; then to_remove+=("$id")
        else                      to_install+=("$id"); fi
      done

      if ((${#to_remove[@]})); then
        mode=$(removal_mode_menu)
        if [[ "$mode" == "2" ]]; then purge_pkgs "${to_remove[@]}"
        else                           remove_pkgs "${to_remove[@]}"; fi
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
echo "Grazie per aver usato StudioBand v$VERSION. Buona produzione!"
