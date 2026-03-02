#!/bin/bash
# Auto-publish: build Hugo + deploy to Cloudflare Pages
set -e

SITE_DIR="/Users/ayintoayin/Desktop/mypodcastlistening"
cd "$SITE_DIR"

# Build site
hugo --minify

# Git commit
git add -A
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
git commit -m "Auto-publish: $TIMESTAMP" || echo "Nothing to commit"
git push origin main || echo "Push failed, continuing with deploy"

# Deploy to Cloudflare Pages
CLOUDFLARE_API_TOKEN="auDXDoHyP3kff6bVIFjLj7FHAcfJiVvdGVaHuTM4" wrangler pages deploy public --project-name=mypodcastlistening --commit-dirty=true

echo "Published at $TIMESTAMP"
