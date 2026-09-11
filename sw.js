/* Service Worker - تحویل/تحول PWA */
var CACHE_NAME = 'delivery-app-v2';
var SHELL_URLS = [
  './',
  './index.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  './icon.svg'
];

/* Install: cache app shell */
self.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open(CACHE_NAME).then(function(cache) {
      return cache.addAll(SHELL_URLS);
    }).then(function() {
      return self.skipWaiting();
    })
  );
});

/* Activate: clean old caches + claim clients */
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

/* Fetch: network-first for API/CDN, stale-while-revalidate for local */
self.addEventListener('fetch', function(event) {
  var url = new URL(event.request.url);

  if (event.request.method !== 'GET') return;

  /* External (Supabase, CDN): network-first */
  if (url.origin !== self.location.origin) {
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
    return;
  }

  /* Local files: stale-while-revalidate */
  event.respondWith(
    caches.open(CACHE_NAME).then(function(cache) {
      return cache.match(event.request).then(function(cached) {
        var fetchPromise = fetch(event.request).then(function(response) {
          if (response && response.status === 200) {
            cache.put(event.request, response.clone());
          }
          return response;
        }).catch(function() {
          return cached;
        });
        return cached || fetchPromise;
      });
    })
  );
});

/* Handle notification click — open/focus the app */
self.addEventListener('notificationclick', function(event) {
  event.notification.close();
  event.waitUntil(
    self.clients.matchAll({type: 'window', includeUncontrolled: true}).then(function(clients) {
      /* Focus existing window if open */
      for (var i = 0; i < clients.length; i++) {
        if (clients[i].url.indexOf('index.html') !== -1 && 'focus' in clients[i]) {
          return clients[i].focus();
        }
      }
      /* Otherwise open new window */
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
    /* Fallback simple notification */
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