function initializeAuth() {
  var config = {
    apiKey: "AIzaSyBFIQbu3jig_f8jLKOe-kCoVGgfkwy_Efg",
    authDomain: "gwaa-games.firebaseapp.com",
    databaseURL: "https://gwaa-games.firebaseio.com",
    projectId: "gwaa-games",
    storageBucket: "gwaa-games.appspot.com",
    messagingSenderId: "795510693974"
  };
  firebase.initializeApp(config);
}

function signInWithPopup() {
  window.open("/login", 'Sign In', 'width=500,height=500');
}

function signOut() {
  firebase.auth().signOut();
}
