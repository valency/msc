<html>
<head>
    <title>Magic Script Compiler</title>
    <?php include_once "lib.php"; ?>
    <link rel="stylesheet" href="css/index.css"/>
    <script src="js/index.js"></script>
</head>
<body>
<div class="container">
    <div class="row">
        <div class="col-md-12">
            <div class="form-group">
                <p>
                    <span class="text-bold text-primary">Magic Script Compiler</span>
                    <small id="script-version" class="text-muted pull-right"></small>
                </p>
                <p>Write your shell script below and compile it into binary!</p>
                <pre id="script-lib"></pre>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-12">
            <div class="form-group">
                <textarea class="form-control" rows="5" id="script-content"></textarea>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-12">
            <div id="btn-set" class="form-group">
                <a class="btn btn-primary btn-xs" href="javascript:msc()">Compile</a>
                <a id="btn-test" class="btn btn-danger btn-xs disabled" href="javascript:msc_test()">Test</a>
                <a id="btn-download" class="btn btn-success btn-xs disabled" href="javascript:void(0)">Download</a>
                <small class="text-muted pull-right">&copy; 2016-2017 <a href='http://deepera.com' target="_blank">Deepera Co., Ltd.</a></small>
            </div>
        </div>
    </div>
</div>
</body>
</html>
