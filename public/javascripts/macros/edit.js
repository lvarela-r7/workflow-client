/* DO NOT MODIFY. This file was compiled Tue, 12 Jul 2011 16:13:10 GMT from
 * /media/sf_work/pro/ui/app/coffeescripts/macros/edit.coffee
 */

(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  jQuery(function($) {
    return $(document).ready(function() {
      $("#modules-table").table({
        searchInputHint: "Search Modules",
        datatableOptions: {
          "aaSorting": [[2, 'asc']],
          "bStateSave": true,
          "aoColumns": [
            {
              "sType": "title-numeric"
            }, null, null, {
              "bSortable": false
            }
          ]
        }
      });
      $('a.add').live('click', function(e) {
        var $dialog, $spinner;
        $spinner = $(this).siblings('img.spinner');
        $spinner.css('visibility', 'visible');
        $dialog = $('<div style="display:hidden"></div>').appendTo('body');
        $dialog.load($('#macro-module-options-url').html(), {
          'module': $(this).parent().siblings('td.fullname').html(),
          'id': $('#macro-id').html()
        }, __bind(function(responseText, textStatus, xhrRequest) {
          $spinner.css('visibility', 'hidden');
          return $dialog.dialog({
            title: "Configure Module",
            width: 400,
            buttons: {
              "Add Action": function() {
                return $(this).find('form').submit();
              }
            }
          });
        }, this));
        return e.preventDefault();
      });
      return $('#action-delete-submit').multiDeleteConfirm({
        tableSelector: '#action_list',
        pluralObjectName: 'actions'
      });
    });
  });
}).call(this);
