document.observe("dom:loaded", function() {

	//
	// Hide the optional Scan Credentials fields unless "Specify additional scan credentials" is checked
	//
	toggle_visibility_with_checkbox(
		$("additional_creds_checkbox"),
		$("additional_creds_fields")
	);

	//
	// Enable the Custom Scan Template Name textfield when a "custom" Scan Template is selected
	//
	var set_custom_scan_template_enablement = function() {
		if ($('nexpose_task_scan_template').value == "custom")
			$('nexpose_task_custom_template').enable();
		else {
			$('nexpose_task_custom_template').value = "";
			$('nexpose_task_custom_template').disable();
		}
		return false;
	};

	$('nexpose_task_scan_template').observe('change', set_custom_scan_template_enablement);

	set_custom_scan_template_enablement();
});
