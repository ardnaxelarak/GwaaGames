<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Gwaa Games Authentication</title>
    <script src="https://www.gstatic.com/firebasejs/5.5/firebase.js"></script>
    <script src="https://cdn.firebase.com/libs/firebaseui/3.5.2/firebaseui.js"></script>
    <script src="auth.js"></script>
    <link type="text/css" rel="stylesheet" href="https://cdn.firebase.com/libs/firebaseui/3.5.2/firebaseui.css" />
    <style>
      body {
        margin: 0;
      }
    </style>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <script type="text/javascript">
      initializeAuth();

      var uiConfig = {
        'signInSuccessUrl': '/',
        'singInFlow': 'popup',
        'callbacks': {
          'signInSuccess': function(user, credential, redirectUrl) {
            if (window.opener) {
              window.close();
              return false;
            } else {
              return true;
            }
          }
        },
        'signInOptions': [
          firebase.auth.GoogleAuthProvider.PROVIDER_ID,
          firebase.auth.EmailAuthProvider.PROVIDER_ID,
        ],
      };
      var ui = new firebaseui.auth.AuthUI(firebase.auth());
      ui.start('#firebaseui-auth-container', uiConfig);
    </script>
  </head>
  <body>
    <div id="firebaseui-auth-container"></div>
  </body>
</html>
