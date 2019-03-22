function createXHR()
{
	var request = false;
	try
	{
		request = new ActiveXObject('Msxml2.XMLHTTP');
	}
	catch (err2)
	{
		try
		{
			request = new ActiveXObject('Microsoft.XMLHTTP');
		}
		catch (err3)
		{
			try
			{
				request = new XMLHttpRequest();
			}
			catch (err1)
			{
				request = false;
			}
		}
	}
	return request;
}

function writelog(filename, user)
{
	var args = Array.prototype.slice.call(arguments, 2);
	var xhr=createXHR();
	var parameters="file=" + filename + "&name=" + user.trim()
	for (var i = 0; i < args.length; i++)
		parameters += "&a_" + i + "=" + args[i];
	xhr.open("POST", "logger.php", true);
	xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
	xhr.send(parameters);
}

function postScore(gamename, user) {
  var args = Array.prototype.slice.call(arguments, 2);
  var xhr = createXHR();
  var parameters = "game=" + gamename + "&name=" + user.trim();
  for (var i = 0; i < args.length; i++) {
    parameters += "&column" + i + "=" + args[i];
  }
  xhr.open("POST", "scores", true);
	xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
	xhr.send(parameters);
}

function writecomment(filename, user, comment)
{
	var xhr = createXHR();
	var parameters = "file=" + filename + "&name=" + user + "&comment=" + comment;
	xhr.open("POST", "comment.php", true);
	xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
	xhr.send(parameters);
}
