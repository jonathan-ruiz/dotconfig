SCREEN_RESOLUTION="$(xdpyinfo | grep dimensions | cut -d' ' -f7)"
BGCOLOR="000000"
convert "$1" -gravity Center -background $BGCOLOR -extent "$SCREEN_RESOLUTION" RGB:- | i3lock --raw "$SCREEN_RESOLUTION":rgb -c $BGCOLOR -i /dev/stdin
