/* DO NOT MODIFY. This file was compiled Tue, 12 Jul 2011 16:13:16 GMT from
 * /media/sf_work/pro/ui/app/coffeescripts/jquery.multiDeleteConfirm.coffee
 */

(function() {
    jQuery(function($) {
        $.multiDeleteConfirm = {
            defaults: {
                pluralObjectName: 'objects'
            },
            bind: function($button, $table, options) {
                return $button.click(function(e) {
                    if ($table.find("input[type=checkbox]").filter(':checked').size() > 0) {
                        return confirm("Are you sure you want to delete the selected " + options.pluralObjectName + "?");
                    } else {
                        alert("Please select " + options.pluralObjectName + " to be deleted.");
                        return e.preventDefault();
                    }
                });
            }
        };
        return $.fn.multiDeleteConfirm = function(options) {
            var $button, $table, settings;
            settings = $.extend({}, $.multiDeleteConfirm.defaults, options, true);
            $button = $(this);
            $table = $(settings.tableSelector);
            return this.each(function() {
                return $.multiDeleteConfirm.bind($button, $table, settings);
            });
        };
    });
}).call(this);
