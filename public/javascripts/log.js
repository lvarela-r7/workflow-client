$(document).ready(function() {
    $(".master_checkbox").click(function() {
        if ($(".master_checkbox").attr("checked") == "checked") {
            $(".child_checkbox").prop("checked", true);
        }
        else {
            $(".child_checkbox").prop("checked", false);
        }
    });
})