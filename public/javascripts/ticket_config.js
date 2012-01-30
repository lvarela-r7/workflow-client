jQuery.noConflict();
jQuery(document).ready(function() {
    jQuery("#client_selector").change(function() {
        load_selected_client();
    });

    jQuery("#wsdl_operations").change(function() {
        load_wsdl_div();
    });
});

jQuery(document).ready(function() {
    load_selected_client();
    load_wsdl_div();
});

// Whether or not to show the basic authentication dialog
jQuery(document).ready(function() {
    basic_auth_checkbox = jQuery("#use_basic_auth_checkbox");
   if (basic_auth_checkbox)
   {
       // Load the div
       basic_auth_div = jQuery("#soap_headers");
       if (basic_auth_checkbox.attr("checked"))
       {
           basic_auth_div.show();
       }
       else
       {
           basic_auth_div.hide();
       }

       // Setup the function on the checkbox
       basic_auth_checkbox.click(function() {
        if (basic_auth_checkbox.attr("checked"))
        {
            basic_auth_div.show();
        }
        else
        {
           basic_auth_div.hide();
        }
    });
   }
});

function load_selected_client() {
    var val = jQuery("#id_selected").val();
    jQuery('.nexpose_no_test_ticket').hide();
    jQuery("div.ticket_client_config").hide();
    jQuery('#create_test_ticket_btn').attr("disabled", false);

    if (val == "Jira3x") {
        jQuery('#ticket-mapping-bar').show();
        jQuery("div#jira3").show();
    }
    else if (val == "Jira4x") {
        jQuery('#ticket-mapping-bar').show();
        jQuery("div#jira4").show();
    }
    else if (val == "Nexpose") {
        jQuery('#ticket-mapping-bar').hide();
        jQuery('#create_test_ticket_btn').attr("disabled", true);
        jQuery('.nexpose_no_test_ticket').show();
        jQuery("div#nexpose").show();
    }
    else {
        jQuery('#ticket-mapping-bar').hide();
        jQuery("div#soap").show();
    }
}

function load_wsdl_div() {
    var val = jQuery("#wsdl_operations").val();
    var base_wsdl_div_name = "#wsdl_op_";
    var index = 0;

    var current_div = base_wsdl_div_name + index;
    var div_object = jQuery(current_div);

    while (div_object.size() > 0) {
        if (val == index) {
            div_object.show();
        }
        else {
            div_object.hide();
        }
        index = index + 1;
        current_div = base_wsdl_div_name + index;
        div_object = jQuery(current_div);
    }
}

jQuery(document).ready(function() {
    var switchButton;
    switchButton = function($button) {
        if ($button.hasClass('expanded')) {
            $button.removeClass('expanded');
            return $button.addClass('collapsed');
        } else {
            $button.removeClass('collapsed');
            return $button.addClass('expanded');
        }
    };
    jQuery('#ticket-client-config-bar').click(function() {
        jQuery('div.ticket-client').slideToggle();
        return switchButton(jQuery(jQuery('#ticket-client-expander')));
    });
    jQuery('#ticket-mapping-bar').click(function() {
        jQuery('div.ticket-mapping').slideToggle();
        return switchButton(jQuery(jQuery('#ticket-mapping-expander')));
    });
    jQuery('#ticket-format-bar').click(function() {
        jQuery('div.ticket-format').slideToggle();
        return switchButton(jQuery(jQuery('#ticket-format-expander')));
    });
    jQuery('#ticket-rules-bar').click(function() {
        jQuery('div.ticket-rules').slideToggle();
        return switchButton(jQuery(jQuery('#ticket-rules-expander')));
    });
});