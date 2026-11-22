/* Fußball-Live-Center – Service Worker: hält die App-Dateien offline bereit.
   Spieldaten werden NICHT hier zwischengespeichert (das übernimmt die App selbst mit Zeitstempel). */
const CACHE = 'flc-app-v2';
const FILES = ['Fussball_Live_Center.html', 'Bundesliga_1.html', 'Bundesliga_2.html', 'Kreisoberliga_Saalekreis.html',
  'manifest.webmanifest', 'icon-192.png', 'icon-512.png', 'apple-touch-icon.png'];
self.addEventListener('install', e => { e.waitUntil(caches.open(CACHE).then(c => c.addAll(FILES)).then(() => self.skipWaiting())); });
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(k => Promise.all(k.filter(x => x !== CACHE).map(x => caches.delete(x)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  const u = new URL(e.request.url);
  if (e.request.method !== 'GET' || u.origin !== location.origin) return; // API und FUSSBALL.DE immer direkt aus dem Netz
  e.respondWith(fetch(e.request).then(r => {             // zuerst Netz (immer neueste Version) ...
    const copy = r.clone(); caches.open(CACHE).then(c => c.put(e.request, copy)); return r;
  }).catch(() => caches.match(e.request, { ignoreSearch: true })));  // ... ohne Netz aus dem Speicher
});
