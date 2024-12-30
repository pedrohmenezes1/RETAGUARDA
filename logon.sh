#!/bin/bash
# Description: Logon Script (Executed with session user ID)
# Ubuntu 24.04 Update - Configuration Script for CID (Closed In Directory)

# Get Ubuntu Version and GNOME Version
ubuntu_version=$(lsb_release -rs)
gnome_version=$(gnome-shell --version | cut -d' ' -f3)

# Add your script below:
echo "1 - Copying Winthor configuration"
cp -f $NETLOGON/scripts_cid/winthor_config.sh $HOME

# Configuração barra de ferramentas no GNOME
echo "5 - Configuring toolbar"
if [[ "$gnome_version" == "46"* || "$gnome_version" == "45"* ]]; then
    # Para GNOME 46 ou 45
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 26
    gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true
    gsettings set org.gnome.shell.extensions.ding start-corner top-left
else
    # Configuração para versões anteriores
    echo "GNOME version not detected as 42 or 43, skipping toolbar configuration."
fi

# Configuração de execução de scripts
echo "6 - Configuring script execution"
gsettings set org.gnome.nautilus.preferences executable-text-activation launch

# Configuração de exibição no Nautilus
echo "7 - Configuring Nautilus list view"
gsettings set org.gnome.nautilus.preferences default-folder-viewer "list-view"

# Exibir nome do usuário na barra superior (GNOME)
echo "8 - Configuring user name display on the panel"
gsettings set com.canonical.indicator.session show-real-name-on-panel true

# Configuração do VNC
echo "9 - Configuring VNC"
gsettings set org.gnome.Vino require-encryption false
gsettings set org.gnome.Vino icon-visibility never
gsettings set org.gnome.Vino enabled true
gsettings set org.gnome.Vino prompt-enabled false
gsettings set org.gnome.Vino authentication-methods "['vnc']"
gsettings set org.gnome.Vino vnc-password ZGlzdGFjMTA=

# Configuração de bloqueio de tela
echo "10 - Configuring screen lock"
gsettings set org.gnome.desktop.lockdown disable-lock-screen true
gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.session idle-delay 0

# Configuração de Conky
cp -f /usr/share/applications/conky.desktop $HOME/.config/autostart/conky.desktop
cp -f /usr/share/applications/vino.desktop $HOME/.config/autostart/vino.desktop
cp -f /opt/Config/conkyrc $HOME/.conkyrc

# Criando atalhos para o usuário
echo "11 - Copying desktop shortcuts"
xdg-desktop-icon install --novendor /usr/share/applications/arquivos.desktop
xdg-desktop-icon install --novendor /usr/share/applications/arquivos-mcz.desktop

# Configuração de plano de fundo
echo "12 - Setting up background image"
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/warty-final-ubuntu.png'

# Configuração da página inicial do Firefox e Chrome
echo "user_pref(\"browser.startup.homepage\", \"http://intranet.tupan.net/\");" >> $HOME/.mozilla/firefox/*.default*/prefs.js
echo "user_pref('browser.startup.homepage', 'http://intranet.tupan.net/');" >> $HOME/.config/google-chrome/Default/Preferences

# Criando ícone do WinThor
echo "13 - Configuring WinThor icon"
chmod 777 $HOME/winthor_config.sh
/bin/bash $HOME/winthor_config.sh
rm $HOME/winthor_config.sh

# Atualizando imagem da tela de logon.
cp -f $NETLOGON/linux/warty-final-ubuntu.png /usr/share/backgrounds

# Copiar atalhos e arquivos de configuração
cp -f $NETLOGON/linux/Imagens/ubuntu-logo.png  /usr/share/plymouth/ubuntu-logo.png
cp -f $NETLOGON/linux/Icones/*.png /opt/Icones/
cp -f $NETLOGON/linux/Atalhos/*.desktop /usr/share/applications/
cp -f $NETLOGON/linux/Conky/* /opt/Config/
cp -f $NETLOGON/linux/Atalhos/ip /usr/share/applications/ip
cp -f $NETLOGON/linux/Instaladores/sitefwebjws.jnlp /usr/share/applications/sitefwebjws.jnlp
cp -f /opt/Config/conkyrc /etc/skel/.conkyrc
cp -f /usr/share/applications/conky.desktop /etc/skel/.config/autostart/conky.desktop
cp -f /usr/share/applications/vino.desktop /etc/skel/.config/autostart/vino.desktop
chmod 777 -R /opt/Icones
chmod 777 -R /opt/Config
chmod 777 -R /opt/Atalhos
chmod 777 /usr/share/plymouth/ubuntu-logo.png

# Garantir permissão de execução nos atalhos
chmod +x /usr/share/applications/*.desktop

# Configurar permissões e permitir a execução sem intervenção
chmod 777 /usr/share/applications/*.desktop

# Ajustar permissões no novo usuário para atalhos e arquivos
if [ ! -f "/usr/share/applications/winthor" ];then
    cp -f $NETLOGON/linux/Atalhos/winthor /usr/share/applications/winthor
    chmod +x /usr/share/applications/winthor
fi

# Certificar-se de que o sistema permita execução sem intervenção
gsettings set org.gnome.desktop.applications.allow-insecure-executables true

# Exibir aviso legal ao logar
zenity --info --title="AVISO LEGAL | DISPAN Transporte" \
       --text="AVISO LEGAL | DISPAN Transporte\n\nEste é um ativo/serviço de informação ou recurso computacional da 'DISPAN TRANSPORTE RODOVIÁRIO LTDA', o qual pode ser acessado e utilizado somente por usuários previamente autorizados.\n\nEm caso de acesso e uso não autorizado ou indevido deste sistema, ou demais sistemas disponibilizados, que decorram no tratamento irregular de dados pessoais, sensíveis e estratégicos da empresa, o infrator estará sujeito a sanções cabíveis nas esferas administrativa, trabalhista, cível e criminal.\n\nEste ativo/serviço de informação ou recurso computacional é monitorado, não havendo expectativa de privacidade na sua utilização.\n\nA liberação ao acesso destas ferramentas não constitui consentimento absoluto aos termos aqui expostos." \
       --width=500 --height=300

# Fim do script
exit
