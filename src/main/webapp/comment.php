<?php
$name = $_POST['name'];
$comment = $_POST['comment'];
$filename = $_POST['file'];

$comment = nl2br(htmlspecialchars($comment));

$file = fopen($filename, "a") or exit("Unable to open file!");
$array = array($name, $comment, date("H:i:s \o\\n d F Y", time()));
fputcsv($file, $array);
fclose($file);
?>
