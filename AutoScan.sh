#!/bin/bash

host=$1
RHOST=$(cat VersionMapping | grep 80/tcp | awk '/tcp/ {print $1}' | sed 's/tcp/ /' | sed 's/^\///;s/\// /g' | sed -e 's/\s\+//g')

NMAP_Scans () {
  InitialScan=$(nmap -sS $host | awk '/tcp/ {print $1}' | sed 's/^\///;s/\// /g' | sed 's/tcp/ /' | tr -d '\n' | sed -e 's/\s\+/,/g' | sed 's/.$//')
  VersionMappingScan=$(nmap -sV --version-intensity 5 -A -O -oN VersionMapping -p$InitialScan $host)
  ScriptScanning=$(nmap -sV -Pn --script=default,vuln -oN Script -p$InitialScan $host)
  clear
  echo -e "\n[+] NMAP Scan is Complete"
  DIRB_Scan
  }

DIRB_Scan () {
  if [[ $RHOST -eq 80 ]]; then
    clear
    echo -e "\nStarting Dirb Scan\n"
    dirb http://$host:$RHOST/ -rz 10 -o Dirb Scan
  else
    echo "Does not meet 80"
  fi
  }

Initialize () {
  if [[ -n "$host" ]]; then
    echo "[+]Starting NMAP Scans"
    NMAP_Scans
  else
    echo "[!] Please include a host [ex: sudo $0 10.10.10.10]"
    exit
  fi
  }

Initialize
