<html>
<head>
    <title>Magic Script Compiler</title>
    <?php include_once "lib.php"; ?>
    <script src="js/file.js"></script>
</head>
<body>
<div class="vertical-center">
    <div class="container">
        <?php include_once "header.php"; ?>
        <hr/>
        <div class="row">
            <div class="col-md-12">
                <table id="table-files" class="table table-hover table-condensed">
                    <thead>
                    <tr>
                        <th>File Name</th>
                        <th>Modification Time</th>
                        <th>File Size</th>
                        <th>Operations</th>
                    </tr>
                    </thead>
                    <tbody>
                    <?php if ($handle = opendir('./scripts/')) {
                        while (false !== ($entry = readdir($handle))) {
                            if (!is_dir('./scripts/' . $entry) && pathinfo($entry, PATHINFO_EXTENSION) == "ms") {
                                echo "<tr>";
                                echo "<td><a href='scripts/" . $entry . "' target='_blank'><i class='fa fa-file-o'></i> " . $entry . "</a></td>";
                                echo "<td>" . date("Y-m-d H:i:s", filemtime('./scripts/' . $entry)) . "</td>";
                                echo "<td>" . number_format(filesize('./scripts/' . $entry)) . " Bytes</td>";
                                echo "<td>";
                                echo "<a href='editor.php?session=" . basename($entry, ".ms") . "' target='_blank' class='btn btn-xs btn-primary'><i class='fa fa-edit'></i> Edit</a> ";
                                echo "<a href=\"javascript:delete_file('" . $entry . "')\" class='btn btn-xs btn-danger'><i class='fa fa-trash'></i> Delete</a>";
                                echo "</td>";
                                echo "</tr>";
                            }
                        }
                        closedir($handle);
                    } ?>
                    </tbody>
                </table>
            </div>
        </div>
        <hr/>
        <div class="row">
            <div class="col-md-12">
                <?php include_once "footer.php"; ?>
            </div>
        </div>
    </div>
</div>
</body>
</html>
