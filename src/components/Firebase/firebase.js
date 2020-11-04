import app from 'firebase/app';
const firebaseConfig = {
    apiKey: "AIzaSyCOhhuOCeGHjERrOAsaaZEkunSVPL6zGmQ",
    authDomain: "obudai-intelligens-r.firebaseapp.com",
    databaseURL: "https://obudai-intelligens-r.firebaseio.com",
    projectId: "obudai-intelligens-r",
    storageBucket: "obudai-intelligens-r.appspot.com",
    messagingSenderId: "401180364872",
    appId: "1:401180364872:web:1e3148cf4e1c824463887d",
    measurementId: "G-C64EBF89L3"
  };
  class Firebase {
    constructor() {
      app.initializeApp(firebaseConfig);
    }
  }
   
  export default Firebase;