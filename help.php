<html>
<head>
    <title>Magic Script Compiler</title>
    <?php include_once "lib.php"; ?>
    <script src="lib/ace-1.2.5/src-min-noconflict/ace.js"></script>
    <script src="js/help.js"></script>
</head>
<body>
<div class="container">
    <?php include_once "header.php"; ?>
    <div class="row">
        <div class="col-md-3">
            <div id="help-contents" class="list-group list-group-root well"></div>
        </div>
        <div class="col-md-9">
            <textarea id="script-content"></textarea>
            <?php include_once "footer.php"; ?>
        </div>
    </div>
</div>
</body>
</html>
