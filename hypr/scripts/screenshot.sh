#!/bin/bash

DIR="$HOME/Pictures/screenshots/"
NAME="screenshot_$(date +%d%m%Y_%H%M%S).png"

option2="Selected area"
option3="Fullscreen (delay 3 sec)"

options="$option2\n$option3"

choice=$(echo -e "$options" | rofi -dmenu -replace -config ~/dotfiles/rofi/config-screenshot.rasi -i -no-show-icons -l 2 -width 30 -p "Take Screenshot")

case $choice in
    $option2)
        grim -g "$(slurp)" "$DIR$NAME"
        xclip -selection clipboard -t image/png -i "$DIR$NAME"
        notify-send "Screenshot created and copied to clipboard" "Mode: Selected area"
        swappy -f "$DIR$NAME"
    ;;
    $option3)
        sleep 3
        grim "$DIR$NAME" 
        xclip -selection clipboard -t image/png -i "$DIR$NAME"
        notify-send "Screenshot created and copied to clipboard" "Mode: Fullscreen"
        swappy -f "$DIR$NAME"
    ;;
esac
