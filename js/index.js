function msc() {
    $.get("/msc/core/msc.php", function (data) {
        data = eval("(" + data + ")");
        alert(data["status"]);
    });
}