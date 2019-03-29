function postScore(gamename) {
  var columns = Array.prototype.slice.call(arguments, 1);
  if (window.user) {
    window.user.getIdToken(true).then(function(idToken) {
      _postScore(gamename, idToken, columns);
    });
  } else {
    _postScore(gamename, null, columns);
  }
}

function _postScore(gamename, idToken, columns) {
  var data = {
    game: gamename,
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
