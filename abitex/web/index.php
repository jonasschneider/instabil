<?php
require("secret.php");
if(!array_key_exists("timestamp", $_GET) or !array_key_exists("timestamp_sig", $_GET)) {
	die("Zu wenige argumente");
}
$timestamp = intval($_GET["timestamp"]);
$timestamp_sig = $_GET["timestamp_sig"];
#echo "time=" . $timestamp . "<br />";
#echo "sig=" . $timestamp_sig . "<br />";
if(abs(time() - $timestamp) > 30) {
	#die("Zeit abgelaufen; es ist " . time());
	die("Zeit abgelaufen, <a href='http://instabil.heroku.com/current_pdf'>versuch's nochmal</a>");
}
if(hash_hmac("sha1", strval($timestamp), $secret) != $timestamp_sig) {
	die("Falsche signatur");
}
header('Content-type: application/pdf');
header('Content-Disposition: attachment; filename="abi.pdf"');
header("Content-Transfer-Encoding: binary"); 
header("Content-Length: ".filesize("ftp/abi.pdf")); 
@readfile("ftp/abi.pdf");
#echo hmac_sha1(1, 1);

?>

