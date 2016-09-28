var script_file = guid() + ".ms";
var script_editor = null;

$(document).ready(function () {
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
});

function msc() {
    $.post("scripts/writer.php", {
        f: script_file,
        c: script_editor.getValue()
    }, function () {
        $("#script-result").attr("src", "core/exec.php?f=../lib/msc/msc.sh&s=" + script_file);
        $("#btn-download").attr("href", "scripts/" + script_file.replace(".ms", ".sh"));
    });
}