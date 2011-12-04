<?php
require("secret.php");
if(!array_key_exists("key", $_GET)) {
	die("Parameter fehlt");
}
if($_GET["key"] == $enable) {
	file_put_contents("status", "ena");
}

if($_GET["key"] == $disable) {
	file_put_contents("status", "dis");
}
?>
