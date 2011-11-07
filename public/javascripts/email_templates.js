document.observe("dom:loaded", function() {

	var set_exe_attachment_row_visibility = function() {
		if ($('email_template_attach_exe').checked)
			$('exe_attachment_row').show();
		else
			$('exe_attachment_row').hide();
		return false;
	};

	var set_exploit_attachment_row_visibility = function() {
		if ($('email_template_attach_exploit').checked)
			$('exploit_attachment_row').show();
		else
			$('exploit_attachment_row').hide();
		return false;
	};

	$('email_template_attach_exe').observe('click', set_exe_attachment_row_visibility);
	$('email_template_attach_exploit').observe('click', set_exploit_attachment_row_visibility);

	set_exe_attachment_row_visibility();
	set_exploit_attachment_row_visibility();

});
