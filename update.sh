#!/bin/bash
cd /root/scripts/plexity
git reset HEAD > /dev/null 2>&1
git checkout -- . > /dev/null 2>&1
git pull -f
chmod +x *.sh > /dev/null 2>&1
