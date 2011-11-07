/* DO NOT MODIFY. This file was compiled Tue, 12 Jul 2011 16:13:13 GMT from
 * /media/sf_work/pro/ui/app/coffeescripts/macros/index.coffee
 */

(function() {
  jQuery(function($) {
    return $(document).ready(function() {
      return $('#macro-delete-submit').multiDeleteConfirm({
        tableSelector: '#macro_list',
        pluralObjectName: 'macros'
      });
    });
  });
}).call(this);
