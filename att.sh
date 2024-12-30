#!/bin/bash

sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get upgrade
sudo apt-get autoremove

if [ -f /var/run/reboot-required ]; then
  echo 'É nescessário Reiniciar!'
  echo -e $TEXT_RESET
fi

while true; do
  read -p "Pronto para reiniciar? " sn
  case $sn in
  [Ss]* ) reboot; break;;
  [Nn]* ) exit;;
  * ) echo "Digite [S] ou [N]";;
  esac
done