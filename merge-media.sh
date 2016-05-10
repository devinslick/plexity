#!/bin/bash
echo "This script is a placeholder for future reference."
echo "Right now, this simply merges all files alphabetically in /media/files/merge"
echo "The resulting output will be saved as /media/files/merge/output"
echo "..."
ffmpeg -f concat -i <(for f in ./*; do echo "file '/media/files/merge/$f'"; done) -c copy output
echo "Done"
