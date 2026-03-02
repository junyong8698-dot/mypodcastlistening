#!/bin/bash
# Auto-publish: build Hugo + push to GitHub
# Cloudflare Pages will auto-deploy on push

set -e

SITE_DIR="/Users/ayintoayin/Desktop/mypodcastlistening"
cd "$SITE_DIR"

# Build site
hugo --minify

# Git add, commit, push
git add -A
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
git commit -m "Auto-publish: $TIMESTAMP" || echo "Nothing to commit"
git push origin main
echo "Published at $TIMESTAMP"
