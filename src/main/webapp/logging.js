function postScore(gamename, user) {
  var data = {
    game: gamename,
    name: user.trim()
  };

  var args = Array.prototype.slice.call(arguments, 2);
  for (var i = 0; i < args.length; i++) {
    data["column" + i] = args[i];
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
