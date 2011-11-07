/* DO NOT MODIFY. This file was compiled Tue, 12 Jul 2011 16:13:08 GMT from
 * /media/sf_work/pro/ui/app/coffeescripts/hosts/show.coffee
 */

(function() {
  jQuery(function($) {
    return $(document).ready(function() {
      return $("#vulns-table").table({
        searchInputHint: "Search Vulns",
        datatableOptions: {
          "bStateSave": true,
          "sPaginationType": "full_numbers",
          "aoColumns": [
            null, {
              "sType": "title-numeric"
            }, null, {
              "bSortable": false
            }
          ],
          "oLanguage": {
            "sEmptyTable": "No Vulns are associated with this Host. Click 'New Vuln' above to create a new one."
          }
        }
      });
    });
  });
}).call(this);
