$(document).ready(function () {
    init_editor("script-content", "sh", false);
});

function msc() {
    $("#script-result").attr("src", "core/exec.php?f=msc.sh");
}