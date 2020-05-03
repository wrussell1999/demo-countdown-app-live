# Demo Countdown - Live View (Flutter)

Hackathon Demo Countdown app to display the demo countdown on both iOS and Android


## Setup

This app uses a Firebase Firestore NoSQL Database

To get this to work with Firebase, you will need to setup 4 apps on Firebase:

1. iOS
2. Android
3. Web
4. macOS (use iOS instructions)

All the instructions can be found [here](https://firebase.google.com/docs/flutter/setup).

For Web, make a file inside `web` called `google-services.js` and paste the creds into it:

```javascript
var firebaseConfig = {
    apiKey: "CREDS",
    authDomain: "CREDS",
    databaseURL: "CREDS",
    projectId: "CREDS",
    storageBucket: "CREDS",
    messagingSenderId: "CREDS",
    appId: "CREDS",
    measurementId: "CREDS"
};
// Initialize Firebase
firebase.initializeApp(firebaseConfig);
```
