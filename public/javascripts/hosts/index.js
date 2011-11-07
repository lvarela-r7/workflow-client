/* DO NOT MODIFY. This file was compiled Tue, 12 Jul 2011 16:13:11 GMT from
 * /media/sf_work/pro/ui/app/coffeescripts/hosts/index.coffee
 */

(function() {
  jQuery(function($) {
    return $(document).ready(function() {
      var $hostsDataTable, $hostsTable, $tagDialog, hostsPath;
      hostsPath = $('#hosts-path').html();
      $hostsTable = $('#hosts-table');
      $hostsDataTable = $hostsTable.table({
        setFilteringDelay: true,
        searchInputHint: "Search Hosts",
        datatableOptions: {
          "bProcessing": true,
          "bServerSide": true,
          "bSortMulti": false,
          "bStateSave": true,
          "sPaginationType": "full_numbers",
          "oLanguage": {
            "sEmptyTable": "No Hosts are associated with this Project. Click 'New Host' above to create a new one.",
            "sProcessing": "Loading..."
          },
          "sAjaxSource": hostsPath,
          "aaSorting": [[9, 'desc']],
          "aoColumns": [
            {
              "mDataProp": "checkbox",
              "bSortable": false
            }, {
              "mDataProp": "address"
            }, {
              "mDataProp": "name"
            }, {
              "mDataProp": "os"
            }, {
              "mDataProp": "version"
            }, {
              "mDataProp": "purpose"
            }, {
              "mDataProp": "services"
            }, {
              "mDataProp": "vulns"
            }, {
              "mDataProp": "tags"
            }, {
              "mDataProp": "updated_at"
            }, {
              "mDataProp": "status",
              "bSortable": false
            }
          ]
        }
      });
      $("#hosts-table_processing").watch('visibility', function() {
        if ($(this).css('visibility') === 'visible') {
          return $('#hosts-table').css('opacity', 0.6);
        } else {
          return $('#hosts-table').css('opacity', 1);
        }
      });
      $tagDialog = $('#tag-dialog');
      $tagDialog.dialog({
        title: "Tag Hosts",
        width: 500,
        height: 350,
        buttons: {
          "Tag": function() {
            return $(this).find('form').submit();
          }
        },
        autoOpen: false,
        open: function(e, ui) {
          var $checkedRows, $tokenInput, tagSearchPath, tokenInputOptions;
          tagSearchPath = $('#search-tags-path').html();
          tokenInputOptions = {
            "theme": "facebook",
            "hintText": "Type in a tag name...",
            "searchingText": "Searching tags...",
            "allowCustomEntry": true,
            "preventDuplicates": true
          };
          $tokenInput = $('#new_host_tags');
          $checkedRows = $("table.list tbody tr td input[type='checkbox']").filter(':checked').parents('tr');
          if (!$tokenInput.data('tokenInputObject')) {
            $tokenInput.tokenInput(tagSearchPath, tokenInputOptions);
          }
          $tokenInput.tokenInput('clear');
          if ($checkedRows.size() === 1) {
            $checkedRows.children('td:nth-child(9)').find('.tag').each(function() {
              var id, name;
              name = $(this).children('span.tag-name').html();
              id = parseInt($(this).children('span.tag-id').html());
              return $tokenInput.tokenInput("add", {
                name: name,
                id: id
              });
            });
          }
          return e.preventDefault();
        }
      });
      $('span.button a.tag').click(function(e) {
        var $checkedHosts;
        $tagDialog.dialog('open');
        $checkedHosts = $("table.list tbody tr td input[type='checkbox']").filter(':checked');
        if ($checkedHosts.size() === 1) {
          $tagDialog.dialog('option', 'title', 'Edit Tags');
        } else {
          $tagDialog.dialog('option', 'title', 'Tag Hosts');
        }
        return e.preventDefault();
      });
      $('#tag-form').submit(function(e) {
        var action;
        action = $(this).attr('action');
        $.ajax({
          url: action,
          type: 'POST',
          data: $('#tag-form, #table-form').serialize(),
          success: function() {
            $tagDialog.dialog('close');
            console.log($hostsDataTable);
            return $hostsDataTable.data('dataTableObject').fnDraw();
          }
        });
        e.preventDefault();
        return false;
      });
      $('img.tags-icon').live('mouseover', function(e) {
        var $tagsDiv, pos, width;
        pos = $(this).offset();
        width = $(this).width();
        $tagsDiv = $(this).siblings('.tags-hover');
        $tagsDiv.css("left", "" + (pos.left + width) + "px");
        $tagsDiv.css("top", "" + (pos.top - $('.dataTables_wrapper').offset().top - 20) + "px");
        return $tagsDiv.show();
      });
      return $('img.tags-icon').live('mouseout', function(e) {
        return $(this).siblings('.tags-hover').hide();
      });
    });
  });
}).call(this);
