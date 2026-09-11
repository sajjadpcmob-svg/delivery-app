/* Service Worker v4 — تحویل/تحول PWA */
var CACHE_NAME = 'delivery-app-v4';
var SHELL_URLS = [
  './',
  './index.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  './icon.svg'
];

/* Install: cache app shell only */
self.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open(CACHE_NAME).then(function(cache) {
      return cache.addAll(SHELL_URLS);
    }).then(function() {
      return self.skipWaiting();
    })
  );
});

/* Activate: clean ALL old caches + claim clients immediately */
self.addEventListener('activate', function(event) {
  event.waitUntil(
    caches.keys().then(function(keys) {
      return Promise.all(
        keys.filter(function(k) { return k !== CACHE_NAME; })
             .map(function(k) { return caches.delete(k); })
      );
    }).then(function() {
      return self.clients.claim();
    })
  );
});

/* Fetch: NEVER cache external requests (Supabase, CDN) */
self.addEventListener('fetch', function(event) {
  var url = new URL(event.request.url);

  /* Skip non-GET requests (POST, PATCH, DELETE used by Supabase client) */
  if (event.request.method !== 'GET') return;

  /* External requests: ALWAYS network-only, no cache fallback */
  if (url.origin !== self.location.origin) {
    event.respondWith(
      fetch(event.request).catch(function() {
        return new Response('', {status: 503, statusText: 'Network unavailable'});
      })
    );
    return;
  }

  /* Local files: network-first (always get latest version) */
  event.respondWith(
    fetch(event.request).then(function(response) {
      if (response && response.status === 200) {
        var clone = response.clone();
        caches.open(CACHE_NAME).then(function(cache) {
          cache.put(event.request, clone);
        });
      }
      return response;
    }).catch(function() {
      return caches.match(event.request);
    })
  );
});

/* Listen for messages from the main app */
self.addEventListener('message', function(event) {
  if (event.data && event.data.action === 'clearCache') {
    caches.keys().then(function(keys) {
      Promise.all(
        keys.filter(function(k) { return k !== CACHE_NAME; })
             .map(function(k) { return caches.delete(k); })
      );
    });
  }
});

/* Handle notification click — open/focus the app */
self.addEventListener('notificationclick', function(event) {
  event.notification.close();
  event.waitUntil(
    self.clients.matchAll({type: 'window', includeUncontrolled: true}).then(function(clients) {
      for (var i = 0; i < clients.length; i++) {
        if (clients[i].url.indexOf('index.html') !== -1 && 'focus' in clients[i]) {
          return clients[i].focus();
        }
      }
      return self.clients.openWindow('./index.html');
    })
  );
});

/* Push event — for future push notification support */
self.addEventListener('push', function(event) {
  if (!event.data) return;
  try {
    var data = event.data.json();
    var title = data.title || 'تحویل/تحول';
    var options = {
      body: data.body || data.message || '',
      icon: './icon-192.png',
      badge: './icon-72.png',
      dir: 'rtl',
      lang: 'fa',
      vibrate: [100, 50, 100, 50, 150],
      tag: 'delivery-push-' + Date.now(),
      renotify: true
    };
    event.waitUntil(self.registration.showNotification(title, options));
  } catch(e) {
    event.waitUntil(
      self.registration.showNotification('تحویل/تحول', {
        body: event.data ? event.data.text() : 'اعلان جدید',
        icon: './icon-192.png',
        dir: 'rtl',
        vibrate: [100, 50, 100, 50, 150]
      })
    );
  }
});