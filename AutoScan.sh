#!/bin/bash

host=$1
GREEN='\033[0;32m'
RED='\033[0;31m'
END='\e[0m'

Initialize () {
  if [[ -n "$host" ]]; then
    echo -e "\n[!] Initializing Scans\n"
    NMAP_Scans
  else
    echo "[!] Please include a host [ex: sudo $0 10.10.10.10]"
    exit
  fi
  }

NMAP_Scans () {
  # clear
  echo -e "\n[!] Starting Initial NMAP Scan\n"
  InitialScan=$(nmap -sS $host | awk '/tcp/ {print $1}' | sed 's/^\///;s/\// /g' | sed 's/tcp/ /' | tr -d '\n' | sed -e 's/\s\+/,/g' | sed 's/.$//')
  echo -e "\e${GREEN}[*] Complete${END}"
  sleep 2
  echo -e "\n[!] Starting Version Mapping NMAP Scan\n"
  VersionMappingScan=$(nmap -sV --version-intensity 5 -A -O -oN VersionMapping-$host -p$InitialScan $host)
  echo -e "\e${GREEN}[*] Complete${END}"
  sleep 2
  echo -e "\n[!] Starting NMAP Script Scan\n"
  ScriptScanning=$(nmap -sV -Pn --script=default,vuln -oN Script-$host -p$InitialScan $host)
  echo -e "\e${GREEN}[*] Complete${END}"
  sleep 2
  echo -e "\n[+] NMAP Scans Complete\n"
  clear
  echo -e "\e${RED}\n------------------------------------- Version Mapping NMAP Scan -------------------------------------\n${END}"
  cat VersionMapping-$host
  echo -e "\e${RED}\n------------------------------------- Script NMAP Scan -------------------------------------\n${END}"
  cat Script-$host
  }

DIRB_Scan () {
  if [[ $HTTP_Main -eq 80 ]]; then
    # clear
    echo -e "\e${RED}\n------------------------------------- Dirb Scan $HTTP_Main -------------------------------------\n${END}"
    dirb http://$host:$HTTP_Main/ Medium-Directory-Wordlists -rz 10 -o Dirb-Medium-$HTTP_Main
    # clear
    echo -e "[+] All Scanning Complete"
  elif [[ $HTTP_Alt -eq 8080 ]]; then
    # clear
    echo -e "\n[!] Starting Dirb Scan\n"
    echo $HTTP_Alt
    # dirb http://$host:$HTTP_Alt/ -rz 10 -o Dirb Scan
    # clear
    echo -e "[+] All Scanning Complete"
  elif [[ $HTTPs_Main -eq 443 ]]; then
    # clear
    echo -e "\n[!] Starting Dirb Scan\n"
    echo $HTTPs_Main
    # dirb http://$host:$HTTPs_Main/ -rz 10 -o Dirb Scan
    # # clear
    echo -e "[+] All Scanning Complete"
  else
    echo -e "[!] Unable to perform Dirb Scanning"
    exit
  fi
  }

Initialize

HTTP_Main=$(cat VersionMapping | grep 80/tcp | awk '/tcp/ {print $1}' | sed 's/tcp/ /' | sed 's/^\///;s/\// /g' | sed -e 's/\s\+//g')
HTTP_Alt=$(cat VersionMapping | grep 8080/tcp | awk '/tcp/ {print $1}' | sed 's/tcp/ /' | sed 's/^\///;s/\// /g' | sed -e 's/\s\+//g')
HTTPs_Main=$(cat VersionMapping | grep 80/tcp | awk '/tcp/ {print $1}' | sed 's/tcp/ /' | sed 's/^\///;s/\// /g' | sed -e 's/\s\+//g')

DIRB_Scan
