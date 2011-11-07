document.observe("dom:loaded", function() {

	//
	// When any of the exploit_type radio buttons are clicked, set the visibility
	// of the exploit chooser
	//
	var set_exploit_chooser_visibility = function() {
		if ($('web_template_exploit_type_single').checked)
			$('exploit_chooser').show();
		else
			$('exploit_chooser').hide();
		return false;
	};

	$('web_template_exploit_type_none').observe('click', set_exploit_chooser_visibility);
	$('web_template_exploit_type_autopwn').observe('click', set_exploit_chooser_visibility);
	$('web_template_exploit_type_single').observe('click', set_exploit_chooser_visibility);

	//
	// When the clone select is blank, disable all other form fields
	//
	disable_fields_if_select_is_blank($("web_template_clone"));
});
