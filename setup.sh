set -euo pipefail

echo "=== Arch security dev setup script ==="

# Atualizando o sistema
sudo pacman -Syu --noconfirm

PKGS=(
  base-devel git vim python python-pip nodejs npm go
  wireshark-qt nmap tcpdump net-tools iproute2
  gdb strace ltrace lsof binutils
  qemu virtualbox virtualbox-host-dkms virtualbox-guest-iso
  docker docker-compose
  python-virtualenv
  openssl openvpn
  john hashcat binwalk
  radare2 apktool smbclient smbclient
  golang-github-miekg-dns # se disponível
  unzip zip p7zip
  zsh
  vim
)

echo "Instalando pacotes via pacman..."
sudo pacman -S --noconfirm "${PKGS[@]}"

echo "Configurando wireshark (permite captura sem root para grupo wireshark)..."
sudo groupadd -f wireshark
sudo usermod -aG wireshark "$USER"
sudo chgrp wireshark /usr/bin/dumpcap || true
sudo chmod 750 /usr/bin/dumpcap || true
sudo setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap || true

#eu já possuo o AUR por padrão sempre que refaço a instalação da OS, mas se caso for necessário:
if ! command -v yay >/dev/null 2>&1; then
  echo "Instalando yay (AUR helper)..."
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  pushd "$tmpdir/yay"
  makepkg -si --noconfirm
  popd
  rm -rf "$tmpdir"
else
  echo "yay já instalado."
fi

AUR_PKGS=(
  metasploit
  burpsuite
  ghidra
  jadx-git
  bettercap
  gobuster
  sqlmap
)

echo "Instalando pacotes AUR..."
yay -S --noconfirm ${AUR_PKGS[*]} || echo "Alguns AURs podem falhar — instale manualmente se necessário."

echo "Instalando ferramentas Python/NPM..."
pip3 install --user pwntools impacket mitmproxy
npm i -g wscat

if pacman -Qs virtualbox | grep -q virtualbox; then
  echo "Habilitando virtualbox (load kernel modules)..."
  sudo modprobe vboxdrv || true
  sudo systemctl enable --now vboxservice || true
fi

if command -v docker >/dev/null 2>&1; then
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER"
  echo "Adicione e relogue-se para aplicar grupo docker."
fi

echo "Instalação concluída. Reinicie a sessão (logout/login) para aplicar grupos (wireshark/docker)."
echo "Recomendo: revisar manualmente Ghidra e Burp (licenças/accept)."

mkdir -p ~/lab/vms ~/lab/ctf ~/lab/tools
echo "Diretório ~/lab criado para VMs/CTFs/tools."

echo "=== FIM do setup.sh ==="
