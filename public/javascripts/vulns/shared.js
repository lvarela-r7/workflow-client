/* DO NOT MODIFY. This file was compiled Tue, 12 Jul 2011 16:13:14 GMT from
 * /media/sf_work/pro/ui/app/coffeescripts/vulns/shared.coffee
 */

(function() {
  jQuery(function($) {
    return $(document).ready(function() {
      var cloneReferenceFields;
      cloneReferenceFields = function() {
        return $('#references tr:last').clone().css('display', 'none').appendTo('#references tbody');
      };
      cloneReferenceFields();
      $('#add-reference').click(function(e) {
        cloneReferenceFields();
        $('#references tr').eq(-2).show();
        return e.preventDefault();
      });
      return $('td.delete a').live('click', function(e) {
        $(this).parents('tr').remove();
        return e.preventDefault();
      });
    });
  });
}).call(this);
