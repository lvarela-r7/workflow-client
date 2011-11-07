/* DO NOT MODIFY. This file was compiled Tue, 12 Jul 2011 16:13:10 GMT from
 * /media/sf_work/pro/ui/app/coffeescripts/tags/index.coffee
 */

(function() {
  jQuery(function($) {
    return $(document).ready(function() {
      var $tagDialog;
      $("#tags-table").table({
        searchInputHint: "Search Tags",
        datatableOptions: {
          "oLanguage": {
            "sEmptyTable": "No Tags are associated with this Project. Click 'New Tag' above to create a new one."
          },
          "aoColumns": [
            {
              "bSortable": false
            }, {}, {
              "bSortable": false
            }, {}, {
              "bSortable": false
            }, {
              "bSortable": false
            }, {
              "bSortable": false
            }
          ]
        }
      });
      $tagDialog = $('#tag-dialog');
      $tagDialog.dialog({
        title: "Edit Tag",
        autoOpen: false,
        width: 600,
        buttons: {
          "Cancel": function() {
            return $(this).dialog('close');
          },
          "Update Tag": function() {
            return $(this).find('form').submit();
          }
        }
      });
      return $('span.button a.edit', '.control-bar').click(function(e) {
        var tag_url;
        if (!$(this).parents('span.button').hasClass('disabled')) {
          tag_url = $("input[type='checkbox']", "table.list").filter(':checked').siblings('a').attr('href');
          $.get(tag_url, function(data) {
            $tagDialog.html(data);
            return $tagDialog.dialog('open');
          });
        }
        return e.preventDefault();
      });
    });
  });
}).call(this);
