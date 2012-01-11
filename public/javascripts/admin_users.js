document.observe("dom:loaded", function() {

    if ($('user_delete')) {
        //
        // Enable the delete button only if at least one User is selected
        //
        var set_delete_button_state = function() {
            var delete_button = $('user_delete');
            var checkboxes = $$('table#users input[type=checkbox]');
            var checked = checkboxes.any(function(e) {
                return e.checked
            });
            if (checked)
                delete_button.enable();
            else
                delete_button.disable();
        };
        set_delete_button_state();

        $$('table#users td input[type=checkbox]').each(function (e) {
            e.observe('click', set_delete_button_state);
        });
    }
    ;

    if ($('user_admin')) {
        //
        // Disable & check all Project Access checkboxes when Administrator is selected
        //
        var set_project_access_state = function() {
            var user_admin = $('user_admin');
            var project_access_checkboxes = $$('#projects input[type=checkbox]');
            if (user_admin.checked) {
                project_access_checkboxes.each(function(e) {
                    e.checked = true;
                    e.disable();
                });
            } else {
                project_access_checkboxes.each(function(e) {
                    e.enable();
                });
            }
        };
        set_project_access_state();

        $('user_admin').observe('click', set_project_access_state);
    }
    ;

});
