/* Service Worker — مدیریت ارسال کالا v6.22 */

var CACHE_NAME = 'delivery-app-v6.22';
var urlsToCache = [
  './Index.html',
  './manifest.json',
  './icons/icon-192.png',
  './icons/icon-512.png'
];

self.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open(CACHE_NAME).then(function(cache) {
      return cache.addAll(urlsToCache);
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', function(event) {
  event.waitUntil(
    caches.keys().then(function(names) {
      return Promise.all(
        names.filter(function(n) { return n !== CACHE_NAME; })
             .map(function(n) { return caches.delete(n); })
      );
    })
  );
  self.clients.claim();
});

self.addEventListener('fetch', function(event) {
  event.respondWith(
    caches.match(event.request).then(function(response) {
      if (response) return response;
      return fetch(event.request).then(function(resp) {
        if (!resp || resp.status !== 200) return resp;
        var rc = resp.clone();
        caches.open(CACHE_NAME).then(function(cache) {
          cache.put(event.request, rc);
        });
        return resp;
      });
    }).catch(function() {
      if (event.request.destination === 'document') {
        return caches.match('./Index.html');
      }
    })
  );
});
