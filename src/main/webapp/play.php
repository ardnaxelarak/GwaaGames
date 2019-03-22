<?php
class game
{
	public $sketchname, $name, $display, $desc;
	public function __construct($pieces)
	{
		$this->sketchname = $pieces[0];
		$this->name = $pieces[1];
		$this->display = $pieces[2];
		$this->desc = $pieces[3];
	}
}

class comment
{
	public $name, $time, $text;
	public function __construct($pieces)
	{
		$this->name = ucwords(trim($pieces[0], " _"));
		$this->text = $pieces[1];
		$this->time = $pieces[2];
	}
}

$game = "";

if (isset($_GET['game']))
	$game = $_GET['game'];

$gamelist = fopen("gamelist", "r") or exit("Game list not found");

$index = -1;

while (($pieces = fgetcsv($gamelist)) !== false)
{
	$curgame = new game($pieces);
	if ($curgame->name == $game)
		$index = count($games);
	$games[] = $curgame;
}

fclose($gamelist);

if ($index < 0)
	$index = count($games) - 1;
	
$curgame = $games[$index];

$comments = array();

if ($commentfile = fopen("comments/" . $curgame->name . "-comments", "r"))
{
	while (($pieces = fgetcsv($commentfile)) !== false)
	{
		$comments[] = new comment($pieces);
	}
	fclose($commentfile);
}

?>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		<title><?php echo $curgame->display; ?></title>
		<meta name="Generator" content="Processing" />
		<style type="text/css">
			body
			{
				background-color: #333; color: #bbb; line-height: normal;
				font-family: Lucida Grande, Lucida Sans, Arial, Helvetica Neue, Verdana, Geneva, sans-serif;
				font-size: 11px; font-weight: normal; text-decoration: none;
				line-height: 1.5em;
			}
			a img
			{ 
				border: 0px solid transparent;
			}
			a, a:link, a:visited, a:active, a:hover
			{ 
				color: #cdcdcd; text-decoration: underline;
			}
			h1
			{
				font-family: Arial, Helvetica Neue, Verdana, Geneva, sans-serif;
				width: 100%; letter-spacing: 0.1em;
				margin-bottom: 1em; font-size: 1.65em;
			}
			canvas
			{
				display: block; 
				outline: 0px;
				margin: 0 auto;
				margin-bottom: 1.5em; 
			}
			#content
			{ 
				margin: 50px auto 0px auto; padding: 25px 25px 15px 25px;
				width: 800px; min-width: 300px; overflow: auto;
				border-left: 1px solid #444; border-top: 1px solid #444; 
				border-right: 1px solid #333; border-bottom: 1px solid #333;
				background-color: #3d3d3d;
			}
			#commentarea
			{
				margin: 50px auto 0px auto; padding: 25px 25px 25px 25px;
				width: 450px; min-width: 300px; overflow: auto;
				border-left: 1px solid #444; border-top: 1px solid #444; 
				border-right: 1px solid #333; border-bottom: 1px solid #333;
				background-color: #3d3d3d;
			}
			h1.commentname
			{
				margin: 0px;
				padding: 0px;
				margin-top: 0px;
				text-align: left;
			}
			p.commenttime
			{
				margin: 0px;
				margin-bottom: 8px;
				padding: 0px;
				text-align: left;
			}
			h3.commenttext
			{
				margin: 0px;
				padding: 0px;
				text-align: left;
			}
			div.comment
			{
				margin: 10px auto 0px auto; padding: 15px 15px 15px 15px;
				width: 400px; min-width: 300px; overflow: auto;
				border-left: 1px solid #444; border-top: 1px solid #444; 
				border-right: 1px solid #333; border-bottom: 1px solid #333;
				background-color: #606060;
			}
		</style>
		<!--[if lt IE 9]>
			<script type="text/javascript">alert("Your browser does not support the canvas tag.");</script>
		<![endif]-->
		<script src="processing.js" type="text/javascript"></script>
		<script src="start.js" type="text/javascript"></script>
		<script src="logging.js" type="text/javascript"></script>
		<script type="text/javascript">
			function submitted()
			{
				var nameValue = window.user;
				var commentValue = document.getElementById('comment').value;
				if (nameValue.trim() == "")
				{
					alert("You must enter a name.");
					return;
				}
				if (commentValue.trim() == "")
				{
					alert("What is the point of leaving a blank comment?");
					return;
				}
				writecomment("comments/<?php echo $curgame->name; ?>-comments", nameValue, commentValue);
				var ch1 = document.getElementById('commenttext');
				alert("Thank you! Your comment has been recorded. Please refresh the page to see it.");
				document.getElementById('comment').value = "";
			}
		</script>
		<script type="text/javascript">
			// convenience function to get the id attribute of generated sketch html element
			function getProcessingSketchId () { return '<?php echo $curgame->sketchname; ?>'; }
		</script>
	</head>
	<body>
		<div id="content">
			<h1><?php echo $curgame->display; ?></h1>
			<div style="text-align:center;">
				<canvas id="<?php echo $curgame->sketchname; ?>" data-processing-sources="<?php echo $curgame->sketchname; ?>.pde" width="730" height="550">
					<p>Your browser does not support the canvas tag.</p>
					<!-- Note: you can put any alternative content here. -->
				</canvas>
				<noscript>
					<p>JavaScript is required to view the contents of this page.</p>
				</noscript>
			</div>
			<p id="description"><?php echo $curgame->desc; ?></p>
			<p><a href="index.html" title="Index">Return to main index</a>
		</div>
		<div id="commentarea">
<?php foreach ($comments as $comment) {?>
			<div class="comment">
				<h1 class="commentname"><?php echo $comment->name; ?></h1>
				<p class="commenttime"><?php echo $comment->time; ?></p>
				<h3 class="commenttext"><?php echo $comment->text; ?></h3>
			</div>
<?php } ?>
			<h1 id="commenttext">Leave a comment!</h1>
			<form id="commentform" action="javascript:submitted()">
				Comment:<br>
				<textarea rows="10" cols="50" id="comment"></textarea><br>
				<input namhe="Submit" type="submit" value="Submit"/>
			</form>
		</div>
	</body>
</html>
