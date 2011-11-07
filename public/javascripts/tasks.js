document.observe("dom:loaded", function() {

	//
	// On Collect Evidence page, disable subfields when "Collect other files" is
	// unchecked
	//
	var set_file_field_state = function() {
		if ($('collect_evidence_task_collect_files').checked) {
			$('collect_evidence_task_collect_files_pattern').enable();
			$('collect_evidence_task_collect_files_count').enable();
			$('collect_evidence_task_collect_files_size').enable();
		} else {
			$('collect_evidence_task_collect_files_pattern').disable();
			$('collect_evidence_task_collect_files_count').disable();
			$('collect_evidence_task_collect_files_size').disable();
		}
		return false;
	};
	set_file_field_state();

	$('collect_evidence_task_collect_files').observe('click', set_file_field_state);

});
