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
                <p class="text-bold text-primary">Magic Script Compiler</p>
                <p id="btn-set">
                    <span>Write your shell script below and compile it into binary!</span>
                    <a id="btn-download" class="btn btn-success btn-xs pull-right" href="javascript:void(0)">Download</a>
                    <a class="btn btn-primary btn-xs pull-right" href="javascript:msc()">Compile</a>
                </p>
            </div>
        </div>
        <div class="col-md-12">
            <div class="form-group">
                <textarea class="form-control" rows="5" id="script-content"></textarea>
            </div>
        </div>
        <div class="col-md-12">
            <div class="form-group">
                <iframe id="script-result" src="javascript:void(0)"></iframe>
            </div>
        </div>
    </div>
</div>
</body>
</html>
