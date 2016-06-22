#!/bin/bash
echo Checking resolution of $*...
width=$(ffprobe -v quiet -print_format json -show_format -show_streams "$*"  | grep width | grep -oE "[[:digit:]]{1,}")
height=$(ffprobe -v quiet -print_format json -show_format -show_streams "$*"  | grep height | grep -oE "[[:digit:]]{1,}")
echo "$width"x"$height"
