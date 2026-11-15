#!/bin/sh
#
# Constants for the brightness service.

set -e

exec 2>&1

self="$(realpath "$0")"
owner="$(stat -c %U "$self")"
folder="$(dirname "$self")"

BRIGHTNESS_FILE="$folder/.brightness"
BACKLIGHT_DEVICE="/sys/class/backlight/intel_backlight/brightness"
