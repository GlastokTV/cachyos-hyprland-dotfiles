#!/usr/bin/env bash

source "$HOME/.config/ml4w/scripts/ml4w-notification-handler"
NOTIFICATION_ICON="dialog-error"
APP_NAME="Bluetooth connection"

set -euo pipefail
# set -e: if any command fails (non-zero exit status), the script stops immediately.
# set -u: using an unset variable is an error (prevents silent bugs).
# set -o pipefail: if a pipeline like a | b is used, the pipeline is considered failed if any command in the pipeline fails (not just the last one)

# Get paired devices
mapfile -t DEV_LINES < <(bluetoothctl devices Paired)

if [ "${#DEV_LINES[@]}" -eq 0 ]; then
  echo "No paired Bluetooth devices found."
  exit 1
fi

# Collect connected device MACs into a set
declare -A is_connected=()
mapfile -t CONN_LINES < <(bluetoothctl devices Connected)

for line in "${CONN_LINES[@]}"; do
  mac="$(awk '{print $2}' <<<"$line")"
  is_connected["$mac"]=1
done

# Build arrays for menu entries
labels=()  # what the user sees in rofi
macs=()    # corresponding MACs

for line in "${DEV_LINES[@]}"; do
  mac="$(awk '{print $2}' <<<"$line")"

  # Everything after the MAC is the name (may include spaces)
  name="$(awk '{ $1=""; $2=""; sub(/^ /,""); print }' <<<"$line")"

  if [ -z "${name// }" ]; then
    name="(no name)"
  fi

  if [[ -n "${is_connected[$mac]:-}" ]]; then
    label="✓ $name (connected) ($mac)"
  else
    label="○ $name (not connected) ($mac)"
  fi

  labels+=("$label")
  macs+=("$mac")
done

# rofi menu items
menu_items="$(printf "%s\n" "${labels[@]}")"

selected="$(
  printf "%s\n" "$menu_items" |
    rofi -dmenu -config ~/.config/rofi/config-bluetooth.rasi -i
)"

# If user cancels, rofi returns empty string
if [ -z "${selected:-}" ]; then
  exit 0
fi

# Extract MAC from the end of the label: "(MAC)"
# Assumes label ends with: " ($mac)"
mac="${selected##*(}"
mac="${mac%)*}"

# Safety: ensure extracted MAC exists in our list
idx=-1
for i in "${!macs[@]}"; do
  if [[ "${macs[$i]}" == "$mac" ]]; then
    idx="$i"
    break
  fi
done

if [[ "$idx" -lt 0 ]]; then
  echo "Selected device not found."
  exit 1
fi

# Ensure Bluetooth is powered on
rfkill unblock bluetooth || true
sleep 1


# Toggle connect/disconnect
if [[ -n "${is_connected[$mac]:-}" ]]; then
  bluetoothctl disconnect "$mac" >/dev/null || notify_user \
    --a "${APP_NAME}" \
    --i "${NOTIFICATION_ICON}" \
    --s "Disconnection failed" \
    --m "" \
    --t 1000
else
  bluetoothctl connect "$mac" >/dev/null || notify_user \
    --a "${APP_NAME}" \
    --i "${NOTIFICATION_ICON}" \
    --s "Connection failed" \
    --m "" \
    --t 1000
fi
