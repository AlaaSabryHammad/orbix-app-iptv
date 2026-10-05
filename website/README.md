# orbix.handaza.cloud

Static landing page (no build step): `index.html`, `styles.css`, `app.js`, `assets/`.
English copy is in the HTML; Arabic lives in `app.js` (`AR`). The language follows the
browser, and the toggle choice is remembered.

## Screenshots

Rendered from the real app with the demo data:

```bash
flutter test tool/website/shots_test.dart --update-goldens
```

Then convert to WebP, one file at a time, e.g.:

```bash
ffmpeg -y -i website/assets/shots/home.png -c:v libwebp -quality 86 website/assets/shots/home.webp
```

## Deploy (Hostinger VPS, behind the shared Traefik)

Server layout: `/docker/orbix-site/{docker-compose.yml, default.conf, site/}`, with the
nginx container `orbix-site` on network `n8n_default`. TLS comes from Traefik
(`mytlschallenge`). The APK is served from `site/download/` and is not in git.

Update the page:

```bash
cd website && tar czf - index.html styles.css app.js assets | ssh root@145.223.82.253 'tar xzf - -C /docker/orbix-site/site'
```

New APK version: upload it to `site/download/`, then update the file name, size and
SHA-256 in `index.html` (two download buttons, specs and hash).

DNS: an `A` record `orbix` → `145.223.82.253` in hPanel (done). To re-trigger the
certificate request (for example after a DNS change), Traefik must see the router
disappear. A quick `docker restart` isn't enough:
`ssh root@145.223.82.253 'docker stop orbix-site; sleep 12; docker start orbix-site'`.
