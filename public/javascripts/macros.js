document.observe("dom:loaded", function() {

	if ($('macro_delete')) {
		//
		// Enable the delete button only if at least one key is selected
		//
		var set_delete_button_state = function() {
			var delete_button = $('macro_delete');
			var checkboxes = $$('table#macros input[type=checkbox]');
			var checked = checkboxes.any(function(e) { return e.checked });
			if (checked)
				delete_button.enable();
			else
				delete_button.disable();
		};
		set_delete_button_state();

		$$('table#macros td input[type=checkbox]').each(function (e) {
			e.observe('click', set_delete_button_state);
		});
	};

});

