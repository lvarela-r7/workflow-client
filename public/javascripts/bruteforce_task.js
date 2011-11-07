document.observe("dom:loaded", function() {

		//
		// Hide the optional SMB/MSSQL options unless the protocol is 
		// actually checked. Would be nice to have something a little
		// less simple for the smb_domain fields, but that can come
		// later.
		//

		toggle_visibility_with_checkbox(
			$("service_SMB"),
			$("smb_preserve_domain_names")
			);

		toggle_visibility_with_checkbox(
			$("service_MSSQL"),
			$("mssql_windows_auth")
			);

});
