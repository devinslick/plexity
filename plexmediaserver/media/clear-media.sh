#!/bin/bash
echo "..."
ffmpeg -i <(for f in ./*; do echo "file '/media/files/merge/$f'"; done) -map_metadata -1 -c:v copy -c:a copy /media/files/output.mp4
echo "Done"
