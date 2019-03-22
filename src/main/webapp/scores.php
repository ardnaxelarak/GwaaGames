<?php
class entry
{
	public $name, $time;
	public $scores;
	
	public function __construct($pieces)
	{
		$this->name = ucwords(trim(str_replace("_", " ", $pieces[0])));
		$time->time = $pieces[1];
		$this->scores = array();
		for ($i = 2; $i < count($pieces); $i++)
			$this->scores[] = $pieces[$i];
	}
}

class subgame
{
	public $name, $scorename, $display, $short;
	public $key;
	public $columns;
	public function __construct($pieces)
	{
		$this->name = $pieces[0];
		$this->scorename = $pieces[1];
		$this->display = $pieces[2];
		$this->short = $pieces[3];
		$this->key = intval($pieces[4]);
		$this->columns = array();
		for ($i = 5; $i < count($pieces); $i++)
			$this->columns[] = $pieces[$i];
	}
}

$key = 0;
$items = 0;
$labels = array();
$games = array();

function cmp($a, $b)
{
	global $key;
	return $b->scores[$key] - $a->scores[$key];
}

$scores = array();

$game = "";

if (isset($_GET['game']))
	$game = $_GET['game'];

$display = "topten";

if (isset($_GET['display']))
	$display = $_GET['display'];

$scorelist = fopen("scorelist", "r") or exit("Score list not found");

$index = -1;

while (($pieces = fgetcsv($scorelist)) !== false)
{
	$curgame = new subgame($pieces);
	if ($curgame->scorename == $game)
		$index = count($games);
	$games[] = $curgame;
}

fclose($scorelist);

if ($index < 0)
{
	$index = count($games) - 1;
	$game = $games[$index]->scorename;
}

$curgame = $games[$index];

$items = count($curgame->columns);
$halfwidth = 120 + 50 * $items;
$key = $curgame->key;

$setkey = -1;
if (isset($_GET['sort']))
{
	$setkey = $_GET['sort'];
	$key = $setkey;
}

if ($setkey >= 0)
	$sortlink = '&sort=' . $key;
else
	$sortlink = '';
?>

<!DOCTYPE html>
<html>
	<head>
		<title>Highscores</title>
		<style>
		body
		{
			text-align:center;
		}
		table
		{
			border-collapse:collapse;
		}
		table.center
		{
			margin-left:auto;
			margin-right:auto;
		}
		th
		{
			text-align:center;
		}
		th, td
		{
			padding:3px;
		}
		table, th, td
		{
			border:1px solid black;
		}
		h1
		{
			text-align:center
		}
		p.center
		{
			text-align:center
		}
		td.right
		{
			text-align:right
		}
		td.left
		{
			text-align:left
		}
		</style>
	</head>
	<body>
		<h1><?php echo $curgame->display; ?></h1>
		<p class="center">Display:
			<a href="scores.php?game=<?php echo $game; ?>&display=all<?php echo $sortlink; ?>">All</a>, 
			<a href="scores.php?game=<?php echo $game; ?>&display=topten<?php echo $sortlink; ?>">Top 10</a>, 
			<a href="scores.php?game=<?php echo $game; ?>&display=each<?php echo $sortlink; ?>">By name</a>
		</p>
		<table class="center" style="border:0px">
			<tr>
				<td class="left" style="border:0px; width:<?php echo $halfwidth; ?>px">
				<?php if ($index > 0) { ?>
					<a href="scores.php?game=<?php echo $games[$index - 1]->scorename; ?>&display=<?php echo $display; ?>"><?php echo $games[$index - 1]->display; ?></a>
				<?php } else { ?>
					&nbsp;
				<?php } ?>
				</td>
				<td class="right" style="border:0px; width:<?php echo $halfwidth; ?>px">
				<?php if ($index < count($games) - 1) { ?>
					<a href="scores.php?game=<?php echo $games[$index + 1]->scorename; ?>&display=<?php echo $display; ?>"><?php echo $games[$index + 1]->display; ?></a>
				<?php } else { ?>
					&nbsp;
				<?php } ?>
				</td>
			</tr>
		</table>
		<table class="center">
			<tr>
				<th style="width:40px">&nbsp;</th>
				<th style="width:200px">Name</th>
			<?php for ($i = 0; $i < $items; $i++) { ?>
				<th style="width:100px"><a href="scores.php?game=<?php echo $game; ?>&display=<?php echo $display; ?>&sort=<?php echo $i; ?>"><?php echo $curgame->columns[$i]; ?></a></th>
			<?php } ?>
			</tr>

<?php
if ($file = fopen("scores/" . $game . "-scores", "r"))
{
	while (($pieces = fgetcsv($file)) !== false)
	{
		$cs = new entry($pieces);
		$scores[] = $cs;
	}

	fclose($file);
}

usort($scores, "cmp");

$i = 1;
$highscore = array();

foreach ($scores as $score)
{
	if ($display == 'all' || ($display == 'topten' && $i <= 10))
	{
?>
			<tr>
				<td class="right"><?php echo $i; ?></td>
				<td class="left"><?php echo $score->name; ?></td>
			<?php foreach ($score->scores as $item) { ?>
				<td class="left"><?php echo $item; ?></td>
			<?php } ?>
			</tr>
<?php
		$i = $i + 1;
	}
}
?>

<?php

if ($display == 'each')
{
	foreach ($scores as $score)
	{
		$name = $score->name;
		if (!isset($highscore[$name]))
		{
			$highscore[$name] = new entry($name);
			foreach ($score->scores as $item)
				$highscore[$name]->scores[] = $item;
		}
		else
		{
			for ($i = 0; $i < $items; $i++)
			{
				if ($highscore[$name]->scores[$i] < $score->scores[$i])
					$highscore[$name]->scores[$i] = $score->scores[$i];
			}
		}
	}
	uasort($highscore, "cmp");
	$j = 1;
	foreach ($highscore as $name => $score)
	{
?>
			<tr>
				<td class="right"><?php echo $j; ?></td>
				<td class="left"><?php echo $name; ?></td>
			<?php foreach ($score->scores as $item) { ?>
				<td class="left"><?php echo $item; ?></td>
			<?php } ?>
			</tr>
<?php
		$j = $j + 1;
	}
}
?>

		</table>
		<p class="center"><a href="index.html">Back to main index</a></p>
	</body>
</html>

