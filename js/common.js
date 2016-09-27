function resize_frame(obj) {
    obj.style.height = obj.contentWindow.document.body.scrollHeight + 'px';
}

function get_url_parameter(p) {
    var sPageURL = window.location.search.substring(1);
    var sURLVariables = sPageURL.split('&');
    for (var i = 0; i < sURLVariables.length; i++) {
        var sParameterName = sURLVariables[i].split('=');
        if (sParameterName[0] == p) {
            return sParameterName[1];
        }
    }
}

function init_editor(selector, mode, readonly) {
    var editor = ace.edit(selector);
    editor.setOptions({
        mode: "ace/mode/" + mode
    });
    if (readonly) {
        editor.setOptions({
            readOnly: true,
            maxLines: 20
        });
    } else {
        editor.setOptions({
            minLines: 20,
            maxLines: 20
        });
    }
    return editor;
}