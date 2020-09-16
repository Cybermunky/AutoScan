#!/bin/bash

host=$1

Initialize () {
  if [[ -n "$host" ]]; then
    echo -e "\n[!] Starting NMAP Scans\n"
    NMAP_Scans
  else
    echo "[!] Please include a host [ex: sudo $0 10.10.10.10]"
    exit
  fi
  }

NMAP_Scans () {
  clear
  echo -e "\n[!] Start Initial NMAP Scan\n"
  InitialScan=$(nmap -sS $host | awk '/tcp/ {print $1}' | sed 's/^\///;s/\// /g' | sed 's/tcp/ /' | tr -d '\n' | sed -e 's/\s\+/,/g' | sed 's/.$//')
  clear
  echo -e "\n[!] Starting Version Mapping NMAP Scan\n"
  VersionMappingScan=$(nmap -sV --version-intensity 5 -A -O -oN VersionMapping -p$InitialScan $host)
  clear
  echo -e "\n[!] Starting NMAP Script Scan\n"
  ScriptScanning=$(nmap -sV -Pn --script=default,vuln -oN Script -p$InitialScan $host)
  clear
  echo -e "\n[+] NMAP Scans Complete\n"
  }

  DIRB_Scan () {
    if [[ $RHOST -eq 80 ]]; then
      clear
      echo -e "\n[!] Starting Dirb Scan\n"
      dirb http://$host:$RHOST/ -rz 10 -o Dirb Scan
      clear
      echo -e "[+] All Scanning Complete"
    else
      echo "Does not meet 80"
    fi
    }

Initialize

RHOST=$(cat VersionMapping | grep 80/tcp | awk '/tcp/ {print $1}' | sed 's/tcp/ /' | sed 's/^\///;s/\// /g' | sed -e 's/\s\+//g')

DIRB_Scan
