document.observe("dom:loaded", function() {
	// close popup
	$('popup_overlay').observe('click', function(e) {
		close_popup();
	});

	// wire-up tabs
	$$('ul.tabs').each(function(tab_group) { 
		new Control.Tabs(tab_group); 
	});
});

function close_popup() {
	$('popup').hide();
}

function fill_in_tag_form(form_elem,tag_id,bool1,bool2,bool3) {
  form_elem.create_tag_name.value = document.getElementById(tag_id).children[0].innerText;
  form_elem.create_tag_desc.value = document.getElementById(tag_id).children[1].innerText;
  form_elem.create_tag_report_summary.checked = bool1;
  form_elem.create_tag_report_detail.checked = bool2;
  form_elem.create_tag_critical.checked = bool3;
  return true;
}

function remove_fields(link) {
	$(link).previous('input[type=hidden]').value = "1";
	$(link).up('.fields').hide();
}

function add_fields(link, content) {
	var new_id = new Date().getTime();
	var regexp = new RegExp("new_object", "g");
	var table = $(link).previous('table');
	var empty_row = table.select('tr.emptyset');
	if (empty_row.size() > 0) {
		empty_row[0].hide();
	};
	// add the content and replace 'new_object' with an ID generated from the current timestamp
	table.insert({
		bottom: content.replace(regexp, new_id)
	});
	// focus the first input field that was inserted
	var rows = table.select('tr');
	var last_row = rows[rows.size()-1];
	last_row.select('input')[0].focus()
}

function show_mitm_warning(element) {
	var value = element.value;
	if (! (value == "127.0.0.1" || value == "localhost")) {
		$('mitm_warning').show();
	} else {
		$('mitm_warning').hide();
	}
}

function update_log() {
	var log_elem = $('log');
	var lines = log_elem.childNodes.length;
	new Ajax.Request('/main/get_log?line=' + lines,
	{
		onSuccess: function(transport)
		{
			var new_lines = transport.responseText;
			var at_bottom = false;
			if( log_elem.scrollHeight && log_elem.scrollTop && log_elem.getHeight())
			{
				at_bottom = (log_elem.scrollHeight - log_elem.scrollTop) <= log_elem.getHeight();
			}

			if (new_lines.length > 0)
			{
				log_elem.insert({bottom: new_lines});
				if (!at_bottom)
				{
					scrollToBottom(log_elem);
				}
			}
		}
	});
}

function scrollToBottom(e) {
	e.scrollTop = e.scrollHeight;
}

function update_task(task_id, progress, info) {
	var task_id = 'task_' + task_id;
	var pct = "" + progress + "%";
	var task_e = $(task_id);

	task_e.select('.progress_value').each(function(e) {
		e.setStyle({ width: pct });
	});

	task_e.select('.progress_percent').each(function(e) {
		e.update(pct);
	});

	task_e.select('.info').each(function(e) {
		e.update(info);
	});
}

function toggle_visibility_with_checkbox(checkbox, div) {
	Element.observe(checkbox, "click", function(e) {
		if (checkbox.checked == true)
			div.show();
		else
			div.hide();
	});
}

/*
 * If the given select element is set to "", disables every other element
 * inside the select's form.
 */
function disable_fields_if_select_is_blank(select) {
	var formElement = Element.up(select, "form");
	var fields = formElement.getElements();

	Element.observe(select, "change", function(e) {
		var v = select.getValue();
		for (var i in fields) {
			if (fields[i] != select && fields[i].type && fields[i].type.toLowerCase() != 'hidden' && fields[i].type.toLowerCase() != 'submit') {
				if (v != "") {
					fields[i].disabled = true
				} else {
					fields[i].disabled = false;
				}
			}
		}
	});
}

function enable_fields_with_checkbox(checkbox, div) {
	var fields;

	if (!div) {
		div = Element.up(checkbox, "div")
	}

	f = function(e) {
		fields = div.descendants();
		var v = checkbox.getValue();
		for (var i in fields) {
			if (fields[i] != checkbox && fields[i].type && fields[i].type.toLowerCase() != 'hidden') {
				if (!v) {
					fields[i].disabled = true
				} else {
					fields[i].disabled = false;
				}
			}
		}
	}
	f();
	Element.observe(checkbox, "change", f);
}

function check_all_with_checkbox(all_checkbox, parent_element) {
	var checkboxes = parent_element.select('input[type=checkbox]');

	// initialize the All checkbox state (checked or not)
	all_checkbox.checked = checkboxes.all(function(e) { return e.checked; });

	// when clicked, toggle all the checkboxes in parent_element
	Element.observe(all_checkbox, "click", function(e) {
		var state = !(all_checkbox.checked);
		checkboxes.each(function(e) { e.checked = all_checkbox.checked });
	});

	checkboxes.each(function(checkbox) {
		// when clicked, re-evaluate the all_checkbox state
		Element.observe(checkbox, "click", function(e) {
			all_checkbox.checked = checkboxes.all(function(e) { return e.checked; });
		});
	});
}

function placeholder_text(field, text) {
	var formElement = Element.up(field, "form");
	var submitButton = Element.select(formElement, 'input[type="submit"]')[0];

	if (field.value == "") {
		field.value = text;
		field.setAttribute("class", "placeholder");
	}

	Element.observe(field, "focus", function(e) {
		field.setAttribute("class", "");
		if (field.value == text) {
			field.value = "";
		}
	});
	Element.observe(field, "blur", function(e) {
		if (field.value == "") {
			field.setAttribute("class", "placeholder");
			field.value = text;
		}
	});
	submitButton.observe("click", function(e) {
		if (field.value == text) {
			field.value = "";
		}
	});
}


function submit_checkboxes_to(path, token) {
	var f = document.createElement('form'); 
	f.style.display = 'none'; 
			
	/* Set the post destination */
	f.method = 'POST'; 
	f.action = path;
		
	/* Create the authenticity_token */
	var s = document.createElement('input'); 
	s.setAttribute('type', 'hidden'); 
	s.setAttribute('name', 'authenticity_token'); 
	s.setAttribute('value', token); 
	f.appendChild(s);
		
	/* Copy the checkboxes from the host form */
	$$("input[type=checkbox]").each(function(e) {
		if (e.checked)  {
			var c = document.createElement('input'); 
			c.setAttribute('type', 'hidden'); 
			c.setAttribute('name',  e.getAttribute('name')  ); 
			c.setAttribute('value', e.getAttribute('value') ); 
			f.appendChild(c);
		}
	})

	/* Look for hidden variables in checkbox form */
	$$("input[type=hidden]").each(function(e) {
		if ( e.getAttribute('name').indexOf("[]") != -1 )  {
			var c = document.createElement('input'); 
			c.setAttribute('type', 'hidden'); 
			c.setAttribute('name',  e.getAttribute('name')  ); 
			c.setAttribute('value', e.getAttribute('value') ); 
			f.appendChild(c);
		}
	})
	
	/* Copy the search field from the host form */
	$$("input#search").each(function (e) {
		if (e.getAttribute("class") != "placeholder") {
			var c = document.createElement('input');
			c.setAttribute('type', 'hidden'); 
			c.setAttribute('name',  e.getAttribute('name')  ); 
			c.setAttribute('value', e.value ); 
			f.appendChild(c);
		}
	});

	/* Append to the main form body */
	document.body.appendChild(f); 	
	f.submit();
	return false;
}

function reveal_tag_rename_field(i) {
  f = document.getElementById("tag_rename_field_" + i);
	f.style.display = "block";
	return true;
}
