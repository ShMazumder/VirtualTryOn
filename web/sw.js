const CACHE_NAME = 'virtual-glasses-v1';
const ASSETS = [
  '/',
  '/index.html',
  '/main.dart.js',
  '/flutter.js',
  '/assets/glasses/',
  '/assets/fonts/',
  '/icons/icon-192.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(ASSETS))
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => response || fetch(event.request))
  );
});