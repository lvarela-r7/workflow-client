
document.observe("dom:loaded", function() {

	enable_fields_with_checkbox($("campaign_do_web"), $("web_settings"));
	enable_fields_with_checkbox($("campaign_do_exe_gen"), $("exe_gen_settings"));
	enable_fields_with_checkbox($("campaign_do_email"), $("email_settings"));
});

