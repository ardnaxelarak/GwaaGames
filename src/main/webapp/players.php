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

class player
{
	public $name;
	public $scores;
	public function __construct($name)
	{
		$this->name = ucwords(trim(str_replace("_", " ", $name)));
		$this->scores = array();
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

$labels = array();
$games = array();

function cmp($a, $b)
{
	global $key;
	if (!isset($a->scores[$key]))
		$asc = 0;
	else
		$asc = $a->scores[$key];
	if (!isset($b->scores[$key]))
		$bsc = 0;
	else
		$bsc = $b->scores[$key];
	return $bsc - $asc;
}

$scores = array();

$display = "scores";

if (isset($_GET['display']))
	$display = $_GET['display'];
	
$displaylink = 'display=' . $display . '&';

$scorelist = fopen("scorelist", "r") or exit("Score list not found");

while (($pieces = fgetcsv($scorelist)) !== false)
{
	$curgame = new subgame($pieces);
	$games[] = $curgame;
}

fclose($scorelist);

$numgames = count($games);

$key = 0;
if ($display == 'count')
	$key = -1;
$setkey = -1;
if (isset($_GET['sort']))
{
	$setkey = $_GET['sort'];
	$key = $setkey;
}

echo "<body>";
if ($setkey >= 0)
	$sortlink = '&sort=' . $key;
else
	$sortlink = '';

if ($display == 'count')
	echo '<h1>' . 'Play counts' . '</h1>';
else
	echo '<h1>' . 'Player high scores' . '</h1>';

echo '<table class="center">';
echo '<tr>';
echo '<th style="width:40px">&nbsp;</th>';
echo '<th style="width:200px">Name</a></th>';
for ($i = 0; $i < $numgames; $i++)
{
	echo '<th style="width:60px"><a href="Players.php?' . $displaylink . 
		 'sort=' . $i . '">' . $games[$i]->short . '</a></th>';
}
if ($display == 'count')
{
	echo '<th style="width:60px"><a href="Players.php?' . $displaylink .
		 'sort=-1">Total</a></th>';
}
echo '</tr>';

foreach ($games as $curgame)
{
	$curscores = array();
	if ($file = fopen("scores/" . $curgame->scorename . "-scores", "r"))
	{
		while (($pieces = fgetcsv($file)) !== false)
		{
			$cs = new entry($pieces);
			$curscores[] = $cs;
		}

		fclose($file);
	}
	
	$scores[] = $curscores;
}

$players = array();

for ($i = 0; $i < $numgames; $i++)
{
	$curscores = array();
	foreach ($scores[$i] as $score)
	{
		$name = $score->name;
		if (!isset($players[$name]))
		{
			$players[$name] = new player($name);
			if ($display == 'count')
			{
				$players[$name]->scores[$i] = 1;
				$players[$name]->scores[-1] = 1;
			}
			else
				$players[$name]->scores[$i] = $score->scores[$games[$i]->key];
		}
		else
		{
			if ($display == 'count')
			{
				if (!isset($players[$name]->scores[$i]))
					$players[$name]->scores[$i] = 1;
				else
					$players[$name]->scores[$i] += 1;
				$players[$name]->scores[-1] += 1;
			}
			else if (!isset($players[$name]->scores[$i]) || 
				$players[$name]->scores[$i] < $score->scores[$games[$i]->key])
				$players[$name]->scores[$i] = $score->scores[$games[$i]->key];
		}
	}
}
	
uasort($players, "cmp");
$j = 1;
foreach ($players as $name => $scorelist)
{
	echo '<tr>';
	echo '<td class="right">' . $j . '.</td>';
	echo '<td class="left">' . $name . '</td>';
	for ($i = 0; $i < $numgames; $i++)
	{
		$item = '&nbsp;';
		if (isset($scorelist->scores[$i]))
			$item = $scorelist->scores[$i];
		echo '<td class="right">' . $item . '</td>';
	}
	if ($display == 'count')
	{
		$item = '&nbsp;';
		if (isset($scorelist->scores[-1]))
			$item = $scorelist->scores[-1];
		echo '<td class="right">' . $item . '</td>';
	}
	echo '</tr>';
	$j = $j + 1;
}

echo "</table>";

echo '<p class="center"><a href="Index.html">Back to main index</a></p>';

echo "</body>";

echo "</html>";
?>
