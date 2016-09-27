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
        <div class="col-md-6">
            <div class="form-group">
                <textarea class="form-control" rows="5" id="script-content"></textarea>
            </div>
        </div>
        <div class="col-md-6">
            <div class="form-group">
                <p>Magic Script Compiler</p>
                <p><a class="btn btn-primary btn-xs" href='javascript:msc()'>Click Me!</a></p>
                <iframe id="script-result" src="javascript:void(0)" onload='resize_frame(this);' style="min-height:300px;"></iframe>
            </div>
        </div>
    </div>
</div>
</body>
</html>
