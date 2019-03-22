<?php
$filename = $_POST['file'];
$name = $_POST['name'];
$array = array($name, date("H:i:s \o\\n d F Y", time()));

for ($i = 0; isset($_POST['a_' . $i]); $i++)
	$array[] = $_POST['a_' . $i];

$file = fopen($filename, "a") or exit("Unable to open file!");
fputcsv($file, $array);
fclose($file);
?>
