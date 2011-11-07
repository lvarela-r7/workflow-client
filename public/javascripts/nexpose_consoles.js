jQuery.noConflict();
jQuery(document).ready(function()
{
	jQuery(".master_checkbox").click(function()
	{
		if (jQuery(".master_checkbox").attr("checked") == "checked")
		{
			jQuery(".child_checkbox").prop("checked", true);
		}
		else
		{
			jQuery(".child_checkbox").prop("checked", false);
		}
	});
});