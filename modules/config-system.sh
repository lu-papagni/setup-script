#!/usr/bin/env bash

function Set-Hostname() {
  local static
  local pretty

  echo "Hostname breve corrente: '$(hostnamectl --static)'"
  echo "Hostname dettagliato corrente: '$(hostnamectl --pretty)'"
  echo "Inserire nuovi hostname (lascia vuoto per ignorare)"

  read -p "Breve: " static 
  read -p "Dettagliato: " pretty 

  [[ -n "$static" ]] && hostnamectl --static hostname "$static"
  [[ -n "$pretty" ]] && hostnamectl --pretty hostname "$pretty"
}

function Setup-System() {
  Set-Hostname
}
