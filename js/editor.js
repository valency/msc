var script_session = null;
var script_editor = null;

$(document).ready(function () {
    $("#header-menu-editor").addClass("label label-default");
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
            bootbox.alert("File not found. Click OK to create a new file.", function () {
                location.href = ".";
            });
        });
    }
    $.get("core/msc.php?f=../lib/msc/msc", function (data) {
        data = eval("(" + data + ")");
        $("#script-version").html("v" + data["VERSION"] + " / " + "<a href='javascript:change_session()'>" + script_session + "</a>");
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
            bootbox.alert("<p>Compiling complete!<br/>You can now click the download button to download the binary file.</p>");
        });
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

function change_session() {
    bootbox.confirm({
        title: "Change File Name",
        message: "<input id='script-session' class='form-control' placeholder='File Name'/>",
        callback: function (confirmed) {
            if (confirmed && $("#script-session").val() != "") {
                script_session = $("#script-session").val();
                $("#script-version>a").html(script_session);
                $("#btn-test").addClass("disabled");
                $("#btn-download").addClass("disabled");
            }
        }
    });
}

