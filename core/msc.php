<?php
// Prepare parameters
$f = $_GET["f"];
// Process
$f = $f . $f;
$r = array(
    'version' => 1,
    'func1' => $f
);
// shell_exec("ls -al");
// Return
echo json_encode($r);


