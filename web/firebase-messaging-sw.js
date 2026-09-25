// Firebase Messaging Service Worker for Web Push Notifications
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

// Initialize Firebase in the service worker
// In production, these parameters match your Firebase project configuration
const firebaseConfig = {
  apiKey: "AIzaSyCtUhTN25iO3zJvyuahM-T_iohqbU978dc",
  authDomain: "society-management-c7642.firebaseapp.com",
  projectId: "society-management-c7642",
  storageBucket: "society-management-c7642.firebasestorage.app",
  messagingSenderId: "545312537010",
  appId: "1:545312537010:web:1e3ec170d99625d1d0ccab",
  measurementId: "G-ES5P2MYD0N"
};

if (firebase.apps.length === 0) {
  firebase.initializeApp(firebaseConfig);
}

const messaging = firebase.messaging();

// Handle background notifications
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message: ', payload);
  const notificationTitle = payload.notification ? payload.notification.title : 'Society Management Alert';
  const notificationOptions = {
    body: payload.notification ? payload.notification.body : 'You have a new society notification.',
    icon: '/icons/Icon-192.png',
    data: payload.data
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
