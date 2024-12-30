#!/bin/bash
# Script de configuração Linux pós formatação 
# Data: 30/12/2024

# Alterar o nome da máquina
echo "Digite o novo nome da máquina: "
read NEW_HOSTNAME
echo "Você digitou: $NEW_HOSTNAME. Está correto? (y/n)"
read -r CONFIRMATION

if [[ "$CONFIRMATION" == "y" || "$CONFIRMATION" == "Y" ]]; then
    sudo hostnamectl set-hostname "$NEW_HOSTNAME"
    echo "Nome da máquina alterado para: $NEW_HOSTNAME"
else
    echo "Nome da máquina não foi alterado. Execute o script novamente se precisar alterar."
    exit 1
fi

# URLs dos aplicativos a serem baixados 
CHROME_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
TEAMVIEWER_URL="wget https://download.teamviewer.com/download/linux/teamviewer-host_amd64.deb"
ONLYOFFICE_URL="wget https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb"


# Adição de repositórios
sudo add-apt-repository ppa:emoraes25/cid -y
sudo add-apt-repository ppa:dawidd0811/neofetch -y
sudo add-apt-repository ppa:linphone/release -y

# Atualização dos repositórios
sudo apt update
sudo apt upgrade -y
sudo apt --fix-broken install -y
sudo apt autoremove -y

# Função para verificar e instalar um pacote
verificar_e_instalar_pacote() {
    local pacote=$1
    echo "Verificando e instalando $pacote..."
    if ! dpkg -l | grep -qii "$pacote"; then
        sudo apt install -y "$pacote"
        if [ $? -ne 0 ]; then
            echo "Falha ao instalar $pacote. Saindo..."
            exit 1
        fi
    else
        echo "$pacote já está instalado."
    fi
}

# Lista de pacotes a serem instalados
PACKAGES=(
    cid
    cid-gtk
    rdesktop
    vino
    samba
	linphone-desktop
    krb5-kdc
    libsecret-tools
	libminizip1
    winbind
    smbclient
    cifs-utils
    libpam-mount
    ntp
	curl
    ntpdate
    libnss-winbind
    libpam-winbind
    ssh
    openssh-server
    conky-all
    software-properties-common
    apt-transport-https
    network-manager-l2tp
    network-manager-l2tp-gnome
    neofetch
	htop
)    
# Instalação dos pacotes
sudo apt install -y "${PACKAGES[@]}"

# Verificação e instalação dos pacotes
for pacote in "${PACKAGES[@]}"; do
    verificar_e_instalar_pacote "$pacote"
done

# Instalar aplicativos Snap
sudo snap install vivaldi

# Remove o LibreOffice e pacotes relacionados
apt remove --purge -y libreoffice* && apt autoremove -y && apt autoclean

# Ajuste do arquivo do NTP e Host
sed -i '9,$d' /etc/systemd/timesyncd.conf
echo -e "\n[Time]\nNTP=retaguarda.intra.net\nFallbackNTP=192.168.3.232" >> /etc/systemd/timesyncd.conf
sed -i 's/^hosts.*/hosts:\ \ \ \ \ \ \ \ \ \ files\ dns\ \mdsn4/' /etc/nsswitch.conf

# Instalação de Aplicativos
mkdir /opt/Icones /opt/Atalhos /opt/Config .config/autostart
mkdir /etc/skel/.config
mkdir /etc/skel/.config/autostart
mkdir /etc/skel/Área\ de\ Trabalho
sudo chmod -R 755 /opt/Icones
sudo chmod -R 755 /opt/Atalhos
sudo chmod -R 755 /opt/Config

# Baixar e instalar Aplicativos
wget "$CHROME_URL" -O google-chrome.deb
sudo dpkg -i google-chrome.deb
rm google-chrome.deb

wget "$TEAMVIEWER_URL" -O teamviewer.deb
sudo dpkg -i teamviewer.deb
rm teamviewer.deb

wget "$ONLYOFFICE_URL" -O onlyoffice-desktopeditors_amd64.deb
sudo dpkg -i onlyoffice-desktopeditors_amd64.deb
rm onlyoffice-desktopeditors_amd64.deb

# Configuração TeamViewer
diretorio="/opt/teamviewer/2tv_bin/"
log="/opt/log-teamviewer-adupdate.txt"

# Verifica se o diretório existe
if [ -d "$diretorio" ]; then
    echo "$(date) - TeamViewer atualizado" >> "$log"
else
    echo "$(date) - TeamViewer instalado" >> "$log"

    # Verifica se o comando de assignment está disponível
    if command -v teamviewer &> /dev/null; then
        teamviewer assignment --id=0001CoABChCUegKwU14R76Lp33qJ-lvOEigIACAAAgAJAEmq-B5abikdgmpjporxcZOGuy1hsscBQCAjxtllvaDfGkB8EZ2O_VVAuDJCYmWo2aFTKoI002i-U819hlyDCINVpGDaj9CHxqFIGT96pfxAG02oawVugXYIJebptSSOD-wlIAEQ0v6siQ0=
        if [ $? -ne 0 ]; then
            echo "$(date) - Falha ao atribuir o TeamViewer" >> "$log"
        fi
    else
        echo "$(date) - Comando 'teamviewer' não encontrado" >> "$log"
        exit 1
    fi
fi

# Configuração do arquivo .conkyrc
if [ ! -f ".conkyrc" ]; then
    smbget smb://ti-distac:Tupaneh10@10.53.0.236/ti-distac/linux/Conky/conkyrc -o /opt/Config/.conkyrc
    cp -f /opt/Config/.conkyrc .conkyrc
    cp -f /opt/Config/.conkyrc /etc/skel/.conkyrc
fi

# Configuração do desktop do Conky
if [ ! -f "opt/conky.desktop" ]; then
    smbget smb://ti-distac:Tupaneh10@10.53.0.236/ti-distac/linux/Conky/conky.desktop -o /opt/Config/conky.desktop
    cp -f /opt/Config/conky.desktop .config/autostart/conky.desktop
    cp -f /opt/Config/conky.desktop /etc/skel/.config/autostart/conky.desktop && sleep 1 && chmod +x /etc/skel/.config/autostart/conky.desktop
fi

# Corrigir pacotes quebrados
sudo apt install -f -y
sudo apt --fix-broken install -y
sudo apt autoremove -y

# Sincronizar horário com o servidor
sudo service ntp stop
sudo ntpdate retaguarda.intra.net
sudo service ntp start

# Instalação do Agente do GLPI
cd /tmp/
	wget http://intranet.tupan.net/infra/glpiagentinstall.sh
		bash glpiagentinstall.sh 

# Função para exibir uma barra de progresso
function exibir_progresso() {
    local intervalo=0.2
    local mensagem=$1
    local i=0
    local caracteres=('|' '/' '-' '\\')

    while true; do
        i=$(( (i + 1) % 4 ))
        echo -ne "\r$mensagem ${caracteres[$i]}"
        sleep $intervalo
    done
}

# Processo de ingresso no domínio
echo "Ingresso no Domínio:"
read -p "Nome de usuário: " DOMAIN_USER
read -s -p "Senha: " DOMAIN_PASS

# Iniciar a função de exibição do progresso em segundo plano
exibir_progresso "Ingressando no domínio... " &

# Armazenar o PID da função de progresso
PID_PROGRESSO=$!

# Executar o ingresso no domínio
sudo cid join domain=retaguarda.intra.net user=$DOMAIN_USER pass=$DOMAIN_PASS --no-kerberos

# Parar a função de exibição do progresso
kill $PID_PROGRESSO > /dev/null 2>&1

# Pergunta sobre reinicialização
while true; do
  echo -e "\nDeseja reiniciar a máquina agora? (y/n)"
  read -r RESTART_OPTION

  case $RESTART_OPTION in
    [Yy])
      reboot
      ;;
    [Nn])
      echo "Você optou por reiniciar manualmente após o ingresso no domínio."
      echo "Lembre-se de reiniciar o sistema para aplicar as configurações."
      break
      ;;
    *)
      echo "Opção inválida. Por favor, digite 'y' para sim ou 'n' para não."
      ;;
  esac
done
