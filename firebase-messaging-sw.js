importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyD6_oXX13CB8ulk4r6nYMbeQdPcsj1o8mU",
  projectId: "memoriumm-32074",
  messagingSenderId: "326812095627",
  appId: "1:326812095627:web:118567fd1bda16e2c0708e"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("Notificació en segon pla:", payload);
});