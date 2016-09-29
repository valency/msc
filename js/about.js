$(document).ready(function () {
    $("#header-menu-about").addClass("label label-default");
    $.get("lib/msc/README.md", function (data) {
        $("#about-panel").html(markdown.toHTML(data));
    });
});
