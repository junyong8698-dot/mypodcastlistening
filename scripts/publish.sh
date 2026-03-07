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

# Ping search engines
echo "Pinging search engines..."
curl -s "https://www.google.com/ping?sitemap=https://www.mypodcastlistening.com/sitemap.xml" > /dev/null
curl -s "https://www.bing.com/ping?sitemap=https://www.mypodcastlistening.com/sitemap.xml" > /dev/null

# IndexNow ping (Bing/Yandex instant indexing)
INDEXNOW_KEY="5409f13c00af69bdccb279458ac78ff7"
INDEXNOW_KEY_LOC="https://www.mypodcastlistening.com/${INDEXNOW_KEY}.txt"

# Get recently modified content URLs
RECENT_URLS=$(hugo list all 2>/dev/null | tail -n +2 | awk -F',' '{print $1}' | head -10 | while read f; do
  slug=$(echo "$f" | sed 's|content/||;s|\.md$|/|;s|_index/|/|')
  echo "https://www.mypodcastlistening.com/${slug}"
done)

for URL in $RECENT_URLS; do
  curl -s "https://api.indexnow.org/IndexNow?url=${URL}&key=${INDEXNOW_KEY}&keyLocation=${INDEXNOW_KEY_LOC}" > /dev/null
done
echo "IndexNow pinged for recent URLs"

echo "Published at $TIMESTAMP"
