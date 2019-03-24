function postScore(gamename, user) {
  var columns = Array.prototype.slice.call(arguments, 2);
  if (window.user) {
    window.user.getIdToken(true).then(function(idToken) {
      _postScore(gamename, user, idToken, columns);
    });
  } else {
    _postScore(gamename, user, null, columns);
  }
}

function _postScore(gamename, user, idToken, columns) {
  var data = {
    game: gamename,
    name: user.trim(),
    token: idToken,
  };

  for (var i = 0; i < columns.length; i++) {
    data["column" + i] = columns[i];
  }

  $.post("scores", data);
}

function writecomment(gamename, user, comment)
{
  var data = {
    game: gamename,
    name: user.trim(),
    comment: comment
  };

  $.post("comment", data);
}
