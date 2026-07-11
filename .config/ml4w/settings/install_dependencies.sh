#!/usr/bin/env bash

source "$HOME/.config/ml4w/scripts/ml4w-notification-handler"

APP_NAME="OS dependencies installer"
NOTIFICATION_ICON="notifications-symbolic"


notify_user \
    --a "${APP_NAME}" \
    --i "${NOTIFICATION_ICON}" \
    --s "Starting dep installation" \
    --t 5000


sudo pacman -S --needed --noconfirm discord steam libreoffice-fresh code


if command -v yay &> /dev/null; then
    echo "Yay installation found, skipping"
else
    echo "Yay installation not found, installing"
    sudo pacman -S --needed --noconfirm base-devel make git
    # The --needed flag avoids reinstallation of up to date packages

    cd ~

    if [ -d ~/yay ]; then
        echo "Found existing yay source code folder, deleting it and performing fresh install"
        rm -rf ~/yay
    fi

    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
fi

yay -S --noconfirm --needed sddm-theme-sugar-candy

sudo truncate -s 0 /etc/sddm.conf
printf '%b' "[Theme]\nCurrent=Sugar-Candy" | sudo tee -a /etc/sddm.conf >/dev/null
# Add images to /usr/share/sddm/themes/Sugar-Candy/Backgrounds to change the background as desired
# The modify the /usr/share/sddm/themes/Sugar-Candy/theme.conf file's "Background" variable to the file desired

echo "SDDM installed and configured, please restart the computer for it to take effect."

if command -v flatpak &> /dev/null; then
    echo "Flatpak installation found, skipping..."
else
    echo "Flatpak installation not found, installing it..."
    sudo pacman -S flatpak
fi

echo "Installing all flatpak dependencies"
flatpak install flathub org.gnome.Calculator com.tomjwatson.Emote app.zen_browser.zen com.github.PintaProject.Pinta
# Flatpak automatically skips already installed packages, no need for manual check
echo "Flatpak dependencies installed succesfully"


notify_user \
    --a "${APP_NAME}" \
    --i "${NOTIFICATION_ICON}" \
    --s "Dep installation finished" \
    --t 5000