#!/bin/bash
echo This script is a placeholder for future reference.
echo Right now, this simply merges all files in /media/files/merge
echo ...
ffmpeg -f concat -i <(for f in ./*; do echo "file '/media/files/merge/$f'"; done) -c copy output
