#!/bin/bash
cd /root/scripts/plexity
git reset HEAD
git checkout -- .
git pull -f
chmod +x *.sh
