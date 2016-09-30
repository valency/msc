<html>
<head>
    <title>Magic Script Compiler</title>
    <?php include_once "lib.php"; ?>
    <script src="lib/ace-1.2.5/src-min-noconflict/ace.js"></script>
    <script src="js/editor.js"></script>
</head>
<body>
<div class="container">
    <?php include_once "header.php"; ?>
    <div class="row">
        <div class="col-md-12">
            <textarea id="script-content"></textarea>
        </div>
    </div>
    <div class="row">
        <div id="btn-set" class="col-md-12">
            <a class="btn btn-primary btn-xs" href="javascript:msc()">Compile</a>
            <a id="btn-test" class="btn btn-danger btn-xs disabled" href="javascript:msc_test()">Test</a>
            <a id="btn-download" class="btn btn-success btn-xs disabled" href="javascript:void(0)">Download</a>
            <?php include_once "footer.php"; ?>
        </div>
    </div>
</div>
</body>
</html>
