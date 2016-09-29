var script_editor = null;

$(document).ready(function () {
    $("#header-menu-help").addClass("label label-default");
    $.get("lib/msc/msc", function (data) {
        $("#script-content").html(data);
        script_editor = init_editor("script-content", "sh", true);
    });
    $.get("core/msc.php?f=../lib/msc/msc", function (data) {
        data = eval("(" + data + ")");
        $("#script-version").html("v" + data["VERSION"]);
        var libraries = data["LIBRARIES"];
        var html = "";
        for (var b in libraries) {
            if (libraries.hasOwnProperty(b)) {
                var functions = libraries[b]["FUNCTIONS"];
                html += "<a href='#item-" + libraries[b]["LINENO"] + "' class='list-group-item' data-toggle='collapse' data-parent='#help-contents'><i class='fa fa-caret-right'></i> " + b + "</a>";
                html += "<div class='list-group collapse' id='item-" + libraries[b]["LINENO"] + "'>";
                for (var u in functions) {
                    if (functions.hasOwnProperty(u)) {
                        html += "<a href='javascript:code_jump(" + functions[u]["LINENO"] + ")' class='list-group-item'>" + u + "</a>";
                    }
                }
                html += "</div>";
            }
        }
        $(".list-group-root").html(html);
        $('.list-group-item').on('click', function () {
            $(".list-group-item").addClass("collapsed");
            $('.fa', this).toggleClass('fa-caret-right').toggleClass('fa-caret-down');
        });
        var list_group = $('#help-contents');
        list_group.on('show.bs.collapse', '.collapse', function () {
            list_group.find('.collapse.in').collapse('hide');
        });
    });
});

function code_jump(line_no) {
    script_editor.gotoLine(line_no);
}