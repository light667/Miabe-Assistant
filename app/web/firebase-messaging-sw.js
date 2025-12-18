importScripts('https://www.gstatic.com/firebasejs/10.13.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.1/firebase-messaging.js');

const firebaseConfig = {
  apiKey: "AIzaSyCHxblJprbNN2TBPWiFDdbQhySyfAS52es",
  authDomain: "polyassistant-d250a.firebaseapp.com",
  projectId: "polyassistant-d250a",
  storageBucket: "polyassistant-d250a.firebasestorage.app",
  messagingSenderId: "39495723329",
  appId: "1:39495723329:web:39625f8b1e91e708a159c0",
  measurementId: "G-MVB5XSJG2X"  // Optional, if you have it
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

// Optional: Add background message handling
messaging.onBackgroundMessage((message) => {
  console.log('Background message received: ', message);
  return self.registration.showNotification(
    message.notification.title,
    {
      body: message.notification.body,
      icon: '/firebase-logo.png'  // Optional icon
    }
  );
});