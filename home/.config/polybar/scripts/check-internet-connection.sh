#!/bin/bash

if ping -q -c 1 -W 1 google.com >/dev/null; then
    echo "󰌘 "  # Replace this with your icon for internet connected
else
    echo "󰌙 "  # Replace this with your icon for no internet
fi

