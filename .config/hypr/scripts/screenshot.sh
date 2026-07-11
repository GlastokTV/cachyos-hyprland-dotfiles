#!/usr/bin/env bash
#                                 __        __ 
#   ___ ___________ ___ ___  ___ / /  ___  / /_
#  (_-</ __/ __/ -_) -_) _ \(_-</ _ \/ _ \/ __/
# /___/\__/_/  \__/\__/_//_/___/_//_/\___/\__/ 
#                                              
# Based on https://github.com/hyprwm/contrib/blob/main/grimblast/screenshot.sh

# -----------------------------------------------------

source "$HOME/.config/ml4w/scripts/ml4w-notification-handler"
NOTIFICATION_ICON="camera-photo-symbolic"

delay_5_seconds="5s"
delay_10_seconds="10s"
delay_20_seconds="20s"
delay_30_seconds="30s"
delay_60_seconds="60s"


####
# Choose Timer
# CMD
timer_cmd() {
    rofi -dmenu -replace -config ~/.config/rofi/config-screenshot.rasi -i -no-show-icons -l 5 -width 30 -p "Select delay for screenshot"
}
# FIXME: For reasons I fail to comprehend, the "Select delay for screenshot" title is not being shown, it would be nice to fix that.

# Ask for confirmation
timer_exit() {
    echo -e "$delay_5_seconds\n$delay_10_seconds\n$delay_20_seconds\n$delay_30_seconds\n$delay_60_seconds" | timer_cmd
}

# Confirm and execute
timer_run() {
    selected_timer="$(timer_exit)"
    if [[ "$selected_timer" == "$delay_5_seconds" ]]; then
        countdown=5
        ${1}
    elif [[ "$selected_timer" == "$delay_10_seconds" ]]; then
        countdown=10
        ${1}
    elif [[ "$selected_timer" == "$delay_20_seconds" ]]; then
        countdown=20
        ${1}
    elif [[ "$selected_timer" == "$delay_30_seconds" ]]; then
        countdown=30
        ${1}
    elif [[ "$selected_timer" == "$delay_60_seconds" ]]; then
        countdown=60
        ${1}
    else
        exit
    fi
}
###


timer() {
    if [[ $countdown -gt 10 ]]; then
        notify_user \
            --a "${APP_NAME}" \
            --i "${NOTIFICATION_ICON}" \
            --s "Taking screenshot in ${countdown}" \
            --m "" \
            --t 1000
        countdown_less_10=$((countdown - 10))
        sleep $countdown_less_10
        countdown=10
    fi
    while [[ $countdown -ne 0 ]]; do
        notify_user \
            --a "${APP_NAME}" \
            --i "${NOTIFICATION_ICON}" \
            --s "Taking screenshot in ${countdown}" \
            --m "" \
            --t 1000
        countdown=$((countdown - 1))
        sleep 1
    done
}


takescreenshot_timer() {
    # The first positional argument of this function MUST be the $option_type_screenshot variable
    sleep 1
    timer
    flameshot gui
}


# Execute Command
if [[ "$1" == '--immediate' ]]; then
    flameshot gui
elif [[ "$1" == '--delayed' ]]; then
    timer_run
    takescreenshot_timer
fi

