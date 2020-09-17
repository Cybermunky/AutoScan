#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33'
END='\e[0m'
HOST=$1

NMAP_Smb () {
  SMB=$(cat AllPorts | grep 445/tcp | awk '/tcp/ {print $1}' | sed 's/tcp/ /' | sed 's/^\///;s/\// /g' | sed -e 's/\s\+//g')
  SMB1=$(cat AllPorts | grep 139/tcp | awk '/tcp/ {print $1}' | sed 's/tcp/ /' | sed 's/^\///;s/\// /g' | sed -e 's/\s\+//g')
  if [[ ${SMB} -eq 145 && ${SMB1} -eq 135 ]]; then
    echo "nmap --script=smb-vuln* -p139,445 -oN NMAP-SMB-VulnCheck"
  elif [[ ${SMB} -eq 145 ]]; then
    echo -e "${RED}[-] Could not identify Port: 445${END}"
    echo -e "${YELLOW}[?] Would you like to force NMAP SMB Vulnerability Scan?${END}"
  elif [[ ${SMB1} -eq 445 ]]; then
    echo -e "${RED}[-] Could not identify Port: 145${END}"
    echo -e "${YELLOW}[?] Would you like to force NMAP SMB Vulnerability Scan?${END}"
  else
    echo -e "${RED}[-] No SMB availability${END}"
  fi
  }

GOBUSTER_Default () {
    RPORT80=$(cat AllPorts | grep 80/tcp | awk '/tcp/ {print $1}' | sed 's/tcp/ /' | sed 's/^\///;s/\// /g' | sed -e 's/\s\+//g')
    if [[ ${RPORT80} -eq 80 ]]; then
      gobuster dir -u http://${HOST}:${RPORT80}/ -w WORDLIST >> GoBuster-Default
    else
      echo -e "${RED}[-] Could not identify Port: 80!${END}"
      echo -e "${YELLOW}[?] Would you like to force GoBuster Scan on Port 80?${END}"
      # NMAP_Smb
    fi
      }

NMAP_Scripts () {
  RPORTS=$(cat AllPorts | sed 's/^\///;s/\// /g' | awk -vORS=, '/tcp/ {print $1}' | sed 's/.$//')
  nmap -sV -Pn --script=default,vuln -oN Script -p${RPORTS} ${HOST}
  GOBUSTER_Default
  }

NMAP_Mapping () {
  RPORTS=$(cat AllPorts | sed 's/^\///;s/\// /g' | awk -vORS=, '/tcp/ {print $1}' | sed 's/.$//')
  nmap -sV --version-intensity 5 -A -O -oN VersionMapping -p${RPORTS} ${HOST}
  NMAP_Scripts
  }

NMAP_Initial () {
  if [[ -z $HOST ]]; then
    echo -e "${RED}[!] Please include a host address! ex: sudo ./$0 10.10.10${END}"
    exit
  elif [[ $HOST =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo -e "${GREEN}[+] Starting Scans${END}"
    nmap -sS -p- -oN AllPorts ${HOST}
    NMAP_Mapping
  else
    echo -e "${RED}[!] Incorrect IP Address${END}"
    exit
  fi
  }

NMAP_Initial
