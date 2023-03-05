# Archlinux on a Slimbook Executive 

The document is divided in two parts:
1. Installation of a plain vanilla Arch Linux
2. Configuration and customization for a development oriented user

## Installation of a plain vanilla Arch Linux

### Fetch the latest Arch linux iso to a USB flash memory

```bash
dd if=/path/to/iso of=/dev/sdX
```
where sdX is the device representing your usb key.

### Set the console keyboard layout

```bash
loadkeys fr
```

### Connect to the internet

```bash
iwctl station wlan0 connect "MiWifi"
ping archlinux.org
```

### Update the system clock

```bash
timedatectl set-ntp true
```

### Partition the disks

To identify disks :

```bash
fdisk -l
lsblk
```

| Partition | Size | Type | Mount point | Comments |
| --------- | ---- | ---- | ----------- | -------- |
| EFI | 512MB | EFI Partition | /boot/efi | You can keep the default one if you have an OS already installed |
| SWAP | 8GB | ext4 | [SWAP] | 8GB for 64GB of RAM is enough |
| Root | 100G | ext4 | / | - |
| Home | ∞ | ext4 | /home | The rest of the hard drive |

To partition the disk :

```bash
fdisk /dev/nvme0n1
```

### Format the partitions

```bash
mkfs.vfat -n “EFI System” /dev/nvme0n1p1
mkswap  /dev/nvme0n1p2
mkfs.ext4 /dev/nvme0n1p3
mkfs.ext4 /dev/nvme0n1p4
```

### Mount the file systems

```bash
mount /dev/nvme0n1p3  /mnt
mount --mkdir /dev/nvme0n1p4 /mnt/home
mount --mkdir /dev/nvme0n1p1 /mnt/boot/efi
swapon /dev/nvme0n1p2
```

### Install base system and essential packages

```bash
pacstrap /mnt base base-devel efibootmgr grub linux linux-firmware \
 networkmanager vim zsh iproute2 intel-ucode
```

### Generate fstab file

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

### Ch-root in the new system:

```bash
arch-chroot /mnt
```

### Set root password

```bash
passwd
```

### Add a new user

```bash
useradd -m -s /bin/zsh mdonnart
passwd mdonnart
```

### Setup sudo

```bash
EDITOR=/usr/bin/vim visudo
```

Add the following line after the "root" user one
```bash
mdonnart ALL=(ALL) ALL
```

### Enable NetworkManager daemon

```bash
sudo systemctl enable NetworkManager
```

### Setup locale configuration

```bash
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
```

Run hwclock to generate /etc/adjtime
```bash
hwclock --systohc
```

- Edit and uncomment /etc/locale.gen
```bash
locale-gen
```

- Add language support:
```bash
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=fr" > /etc/vconsole.conf
```

### Setup network

- Set hostname
```bash
echo "slimbook" > /etc/hostname
```

- Set /etc/hosts file adding
```bash
127.0.0.1   localhost
::1         localhost
127.0.1.1   slimbook.localdomain slimbook
```

### Initramfs

Then execute the following command to re-create the kernel config:
```bash
mkinitcpio -p linux
```

### Setup grub

- Modify the following line in file /etc/default/grub so it looks like the following:
```bash
GRUB_TIMEOUT=1
```

### Install and config grub

```bash
grub-install --boot-directory=/boot --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
grub-mkconfig -o /boot/efi/EFI/arch/grub.cfg
```

### Reboot
You are ready to go, exit from the chroot, unmount partitions and reboot:
```bash
exit
umount -R /mnt
reboot
```

### First boot

Connect to network
```bash
nmtui
```

## Configuration and customization  

Use root account for these operations

### Install graphical environment

First, check that the system is up to date
```bash
pacman -Syu
```

Install graphical environment
```bash
pacman -S wayland sway swaybg swaylock swayidle waybar alacritty wofi
```

Add user to seat group
```bash
usermod -a -G seat mdonnart
```

### Install tools

```bash
pacman -S git exa neovim zip unzip htop tmux neofetch lf spotifyd \
firefox ffmpeg openssh stow fd ripgrep bat brightnessctl fzf \
obsidian gnome-boxes wl-clipboard blueman
```

### Customize pacman

```bash
nvim /etc/pacman.conf
```

Add `ILoveCandy` in options under `Color`

### Setup an AUR wrapper

install yay
```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

Install tools from AUR
```bash
yay -S spotify-tui spotify antigen pfetch wlogout
```

### Install DejaVu Sans Mono NF font & Jetbrains Mono NF 

```bash
cd /home/mdonnart/Downloads
curl -fLo "DejaVuSansMono.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/DejaVuSansMono.zip
curl -fLo "JetbrainsMono.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/JetbrainsMono.zip
unzip DejaVuSansMono.zip -d DejaVuSansMono
unzip JetbrainsMono.zip -d JetbrainsMono
mkdir /home/mdonnart/.fonts
mv DejaVuSansMono /home/mdonnart/.fonts/DejaVuSansMono
mv JetbrainsMono /home/mdonnart/.fonts/JetbrainsMono
```

### Setup sound server

```bash
pacman -S alsa-utils pulseaudio pulseaudio-alsa pulseaudio-bluetooth \
pulseaudio-equalizer pulseaudio-jack pulseaudio-lirc pulseaudio-zeroconf
```

### Install development tools

Use user's account to perform these operations

**JAVA**

```bash
curl -s "https://get.sdkman.io" | bash
sdk install java
sdk install maven
yay -S jdtls
sudo chown -R mdonnart /usr/share/java/jdtls
```

**GO**

```bash
sudo pacman -S go
```

**TYPESCRIPT**

```bash
yay -S nvm
nvm install --lts
nvm use --lts
sudo corepack enable
sudo npm i -g typescript
```

**RUST**

```bash
sudo pacman -S rustup
rustup default stable
rustup component add rust-src
rustup component add rust-analyzer
```

**DOCKER**

```bash
sudo pacman -S docker docker-compose
sudo systemctl enable docker.service
sudo usermod -a -G docker mdonnart
```

**TOOLS**

```bash
sudo pacman -S lazygit dbeaver
yay -S insomnia
```

### Setup dotfiles

```bash
git clone --recurse-submodules https://github.com/maeldonn/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make
```
