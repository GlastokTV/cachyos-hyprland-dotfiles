#!/usr/bin/env bash

source "$HOME/.config/ml4w/scripts/ml4w-notification-handler"

APP_NAME="OS dependencies installer"
NOTIFICATION_ICON="notifications-symbolic"


notify_user \
    --a "${APP_NAME}" \
    --i "${NOTIFICATION_ICON}" \
    --s "Starting dep installation" \
    --t 5000


sudo pacman -S --needed --noconfirm discord steam libreoffice-fresh code evolution gnome-keyring libsecret


### yay configuration start
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
### yay configuration end



### SDDM configuration start
yay -S --noconfirm --needed sddm-theme-sugar-candy

sudo truncate -s 0 /etc/sddm.conf
printf '%b' "[Theme]\nCurrent=Sugar-Candy" | sudo tee -a /etc/sddm.conf >/dev/null

## Set personalized SDDM background image start
sudo rm -f /usr/share/sddm/themes/Sugar-Candy/Backgrounds/Nocturne-of-Steel-and-Glass.png # Delete the file if it exists and avoid errors
sudo cp ~/.mydotfiles/com.ml4w.dotfiles.stable/.config/ml4w/wallpapers/Nocturne-of-Steel-and-Glass.png /usr/share/sddm/themes/Sugar-Candy/Backgrounds/Nocturne-of-Steel-and-Glass.png
# It is important to COPY the file, the SYMLINKS DO NOT WORK for some reason

file="/usr/share/sddm/themes/Sugar-Candy/theme.conf"
new_line='Background="Backgrounds/Nocturne-of-Steel-and-Glass.png"'

sudo awk -v nl="$new_line" '
  BEGIN{done=0}
  /^[[:space:]]*Background="Backgrounds/{
    if(!done){ print nl; done=1; next }
  }
  { print }
' "$file" | sudo tee "${file}.tmp" >/dev/null && sudo mv "${file}.tmp" "$file"

# This command automatically searchs for the first line that starts with 'Background="Backgrounds' (allowing whitespaces) and then replaces it with the
# $new_line variable, which is a symlink created previously
## Set personalized SDDM background image end

echo "SDDM installed and configured, please restart the computer for it to take effect."
### SDDM configuration end



### Flatpak configuration start
if command -v flatpak &> /dev/null; then
    echo "Flatpak installation found, skipping..."
else
    echo "Flatpak installation not found, installing it..."
    sudo pacman -S flatpak
fi

echo "Installing all flatpak dependencies"
flatpak install flathub org.gnome.Calculator com.tomjwatson.Emote app.zen_browser.zen com.github.PintaProject.Pinta org.telegram.desktop
# Flatpak automatically skips already installed packages, no need for manual check
echo "Flatpak dependencies installed succesfully"
### Flatpak configuration end

notify_user \
    --a "${APP_NAME}" \
    --i "${NOTIFICATION_ICON}" \
    --s "Dep installation finished" \
    --t 5000