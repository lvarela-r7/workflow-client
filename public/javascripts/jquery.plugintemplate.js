/* DO NOT MODIFY. This file was compiled Tue, 12 Jul 2011 16:13:15 GMT from
 * /media/sf_work/pro/ui/app/coffeescripts/jquery.plugintemplate.coffee
 */

(function() {
    jQuery(function($) {
        var MyPlugin;
        MyPlugin = (function() {
            MyPlugin.prototype.defaults = {
                hidableClass: 'hidable'
            };
            function MyPlugin($element, options) {
                this.$element = $element;
                this.config = $.extend({}, this.defaults, options, true);
                this.$element.data('MyPlugin', this);
                this.init();
            }

            MyPlugin.prototype.foo = function() {
                return console.log(this);
            };
            MyPlugin.prototype.init = function() {
                if (this.$element.hasClass(this.config.hidableClass)) {
                    return this.$element.hover(function() {
                        return this.$element.hide();
                    });
                }
            };
            return MyPlugin;
        })();
        return $.fn.myPlugin = function(options) {
            var object;
            object = $(this).data('MyPlugin');
            return object || this.each(function() {
                return new MyPlugin($(this), options);
            });
        };
    });
}).call(this);
