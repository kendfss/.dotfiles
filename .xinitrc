#!/bin/sh

export DISPLAY="${DISPLAY:-:0.0}"
export XAUTHORITY="${XAUTHORITY:-/run/user/1000/lyxauth}"

start-x11-pulseaudio
