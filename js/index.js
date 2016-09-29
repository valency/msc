var script_session = null;
var script_editor = null;

$(document).ready(function () {
    // Session and editor
    script_session = get_url_parameter("session");
    if (script_session == null || script_session == "") {
        script_session = guid();
        var script_example = "#!/bin/bash\n";
        script_example += "main() {\n";
        script_example += "    export MS_DEBUG=\"yes\"\n";
        script_example += "    s_import aloha log target\n";
        script_example += "    ms_log_setup $MS_NS.log\n";
        script_example += "#   ms_log_setup\n";
        script_example += "#   ms_utility_demo\n";
        script_example += "    ms_target_demo\n";
        script_example += "}\n";
        $("#script-content").html(script_example);
        script_editor = init_editor("script-content", "sh", false);
    } else {
        $.get("scripts/" + script_session + ".ms", function (data) {
            $("#script-content").html(data);
            script_editor = init_editor("script-content", "sh", false);
        }).fail(function () {
            bootbox.alert("Session not found. Click OK to start a new session.", function () {
                location.href = ".";
            });
        });
    }
    // Libraries
    $.get("core/msc.php?f=../lib/msc/msc", function (data) {
        data = eval("(" + data + ")");
        $("#script-version").html("v" + data["VERSION"] + " / " + "<a href='javascript:change_session()'>" + script_session + "</a>");
        var libraries = data["LIBRARIES"];
        var html = "";
        for (var b in libraries) {
            if (libraries.hasOwnProperty(b)) {
                var functions = libraries[b]["FUNCTIONS"];
                html += "<p><span class='label label-danger'>" + libraries[b]["LINENO"] + "</span><span class='label label-primary'>" + b + "</span>";
                for (var u in functions) {
                    if (functions.hasOwnProperty(u)) {
                        html += " <span class='label label-warning'>" + functions[u]["LINENO"] + "</span><span class='label label-default'>" + u + "</span>";
                    }
                }
            }
            html += "</p>";
        }
        $("#script-lib").html(html);
    });
});

function msc() {
    loading();
    $.post("scripts/writer.php", {
        f: script_session + ".ms",
        c: script_editor.getValue()
    }, function () {
        $.get("core/exec.php?f=../lib/msc/msc.sh&s=" + script_session + ".ms", function (data) {
            $("#btn-test").removeClass("disabled");
            $("#btn-download").removeClass("disabled");
            $("#btn-download").attr("href", "scripts/" + script_session + ".sh");
            bootbox.hideAll();
            bootbox.alert("<p>Compiling complete!<br/>You can not click the download button to download the binary file.</p>");
        });
    });
}

function change_session() {
    bootbox.confirm({
        title: "Change Session",
        message: "<input id='script-session' class='form-control' placeholder='Session ID'/>",
        callback: function (confirmed) {
            if (confirmed) location.href = "?session=" + $("#script-session").val();
        }
    });
}

function msc_test() {
    loading();
    $.get("core/exec.php?f=../scripts/" + script_session + ".sh", function (data) {
        bootbox.hideAll();
        bootbox.alert({
            size: "large",
            message: data
        });
    });

}