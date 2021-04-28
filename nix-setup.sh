#!/bin/bash

#__/\\\______________/\\\_____________________________        
# _\/\\\_____________\/\\\_____________________________       
#  _\/\\\_____________\/\\\_____________________________      
#   _\//\\\____/\\\____/\\\___/\\\____/\\\__/\\\\\\\\\\\_     
#    __\//\\\__/\\\\\__/\\\___\/\\\___\/\\\_\///////\\\/__    
#     ___\//\\\/\\\/\\\/\\\____\/\\\___\/\\\______/\\\/____   
#      ____\//\\\\\\//\\\\\_____\/\\\___\/\\\____/\\\/______  
#       _____\//\\\__\//\\\______\//\\\\\\\\\___/\\\\\\\\\\\_ 
#        ______\///____\///________\/////////___\///////////__
#

# This is my[1] setup script - it's heavily adapted to my usecases
# The code is CC0[2] so feel free to rework and reuse as you see fit.
# Extensively inspired and reworked from: https://github.com/nnja/new-computer

dontask=false

####################
# Helper functions #
####################

# Colorize

# Set the colours you can use
black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
reset=$(tput sgr0) # Resets the style

show_spinner()
{
  local -r pid="${1}"
  local -r delay='0.5'
  SYMBOLS='⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷'
  SPINNER_PPID=$(ps -p "${pid}" -o ppid=)
  while ps a | awk '{print $1}' | grep -q "${pid}"; do
    tput civis
    for c in ${SYMBOLS}; do
      local COLOR
      COLOR=$(tput setaf 5)
      tput sc
      env printf "${COLOR}${c}${SPINNER_NORMAL}"
      tput rc
      env sleep .2
      if [ ! -z "$SPINNER_PPID" ]; then
        SPINNER_PARENTUP=$(ps $SPINNER_PPID)
        if [ -z "$SPINNER_PARENTUP" ]; then
          break 2
        fi
      fi
    done
  done
  tput cnorm
}

spinner() {
  ("$@") &
  show_spinner "$!"
}

# Color-echo. Improved. [Thanks @joaocunha]
# arg $1 = message
# arg $2 = Color
cecho() {
  echo "${2}${1}${reset}"
  return
}

# arg $1 = question
# arg $2 = custom denied message
confirm () {
  if [[ $dontask ]]; then
    return 1
  fi
  read -e -p "${white}[confirm] ${blue}${1} : (Y/N) > ${reset}" OK
  if ! [[ "$OK" =~ ^([yY][eE][sS]|[yY])$ ]]
  then
    if ! [[ "$OK" =~ ^([nN][oO]|[nN])$ ]]
    then
      confirm "$1"
    else
      if [[  $2 ]]
      then
        cecho "$2" $yellow
      else
        cecho "Ok! We'll stop here!" $yellow
      fi
      exit 0
    fi
  fi
}

speak() {
  if [[ $dontask ]]; then
    return 1
  fi
  cecho "[◕ᴥ◕] > ${1}" $green
}

while getopts :y flag
do
  case "${flag}" in
      y) dontask=true;;
  esac
done

if [[ $dontask ]]; then
  cecho "Running with -y, ignoring interactive installation" $red
fi

echo ""
cecho "###############################################" "$red"
cecho "#        THIS IS CURRENTLY ONLY FOR MAC       #" "$red"
cecho "#                                             #" "$red"
cecho "#---------------------------------------------#" "$red"
cecho "#                                             #" "$red"
cecho "#        DON'T RUN CODE YOU FIND ON THE       #" "$red"
cecho "#      INTERNET WITHOUT READING IT FIRST      #" "$red"
cecho "#        YOU'LL EVENTUALLY REGRET IT...       #" "$red"
cecho "#                                             #" "$red"
cecho "#---------------------------------------------#" "$red"
cecho "#                                             #" "$red"
cecho "#          READ THIS CODE THOROUGHLY          #" "$red"
cecho "#         AND EDIT TO SUIT YOUR NEEDS         #" "$red"
cecho "###############################################" "$red"
echo ""


speak "It looks like you're trying to set up a new computer... Just kidding. I'm your friendly installer script!"
speak "This script is interactive! Before doing anything, we'll make sure to ask if it's ok, like this:"
confirm "Is it ok to get started?"
speak "Perfect! Let's do this!"

speak "First things first, have you read over the script? Definitely don't run something from the web without reading it first!"
confirm "Have you read over the script?" "Go check it out and then run this again!"


speak "Alright, now we need sudo to keep this thing running. We'll ask for your password now, ok?"
confirm "OK to ask for sudo?"
## Here we go.. ask for the administrator password upfront
sudo -v
## Run a keep-alive to update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

speak "This script runs primarily on nix. Can we install Nix now?"
confirm "OK to install Nix and setup the needed directories and nix channels?"
curl -L https://nixos.org/nix/install | sh
mkdir -p ~/.config/nix/ ~/.config/nixpkgs/
echo 'max-jobs = auto' >>~/.config/nix/nix.conf
nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --add https://github.com/kwbauson/cfg/archive/main.tar.gz kwbauson-cfg
nix-channel --update
nix-shell '<home-manager>' -A install

speak "Alright! Nix is install and setup with what we need! Now let's pull down the nix config files."
confirm "OK to pull the files we need (git.sr.ht/~wuz/nix)?"
cd ~/.config/nixpkgs
git@git.sr.ht:~wuz/nix



