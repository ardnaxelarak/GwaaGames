<nav class="navbar navbar-light bg-light">
  <span>
    <button class="btn btn-success btn-signin" type="button">Sign In</button>
    <button class="btn btn-danger btn-signout" type="button">Sign Out</button>
  </span>
  <span class="navbar-brand name-span">
    <a class="display-name"></a> (<a class="update-name-link" href="#">change</a>)
  </span>
</nav>

<script type="text/javascript">
  function updateName() {
    var newname = prompt("Enter the name you would like displayed in the high scores");
    if (newname !== null && newname != "" && window.user) {
      window.user.updateProfile({
        displayName: newname
      }).then(function() {
        authStateChanged(window.user);
      }, function(error) {
        console.log("error!");
      });
    }
  }

  function authStateChanged(user) {
    if (user) {
      $('.btn-signin').hide();
      $('.btn-signout').show();
      $('.name-span').show();
      $('.display-name').text(user.displayName);
      window.user = user;
    } else {
      $('.btn-signin').show();
      $('.btn-signout').hide();
      $('.name-span').hide();
      window.user = null;
    }
  }

  function initApp() {
    $('.btn-signin').on('click', signInWithPopup);
    $('.btn-signout').on('click', signOut);
    $('.update-name-link').on('click', function(e) {
      updateName();
      e.preventDefault();
    });
    firebase.auth().onAuthStateChanged(authStateChanged);
  }

  window.addEventListener('load', initApp);
</script>
