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
	die("Zeit abgelaufen, klick auf <a href='http://instabil.heroku.com'>instABIl</a> auf den Link zum PDF.");
}
if(hash_hmac("sha1", strval($timestamp), $secret) != $timestamp_sig) {
	die("Falsche signatur");
}
header('Content-type: application/pdf');
header('Content-Disposition: attachment; filename="abi.pdf"');
@readfile("abi.pdf");
#echo hmac_sha1(1, 1);

?>

