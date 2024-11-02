#!/usr/bin/env bash

function Setup-DesktopEnvironment() {
  if [[ -v KDE_SESSION_VERSION ]]; then
    local plasma_profile

    echo "KDE Plasma (ver. $KDE_SESSION_VERSION) rilevato."

    read -p "Nome del profilo KDE da caricare: " plasma_profile
    python3 -m konsave -a "$plasma_profile"
  fi
}
