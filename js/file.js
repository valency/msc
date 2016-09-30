$(document).ready(function () {
    $("#header-menu-file").addClass("label label-default");
    $("#table-files").DataTable();
});

function delete_file(file) {
    bootbox.confirm("Are you sure? This action cannot be undone.", function (confirmation) {
        if (confirmation) {
            $.ajax({
                type: "DELETE",
                url: "scripts/index.php?file=" + file,
                dataType: "json",
                complete: function (data) {
                    location.reload();
                }
            });
        }
    });
}
