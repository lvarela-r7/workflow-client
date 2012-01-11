/* DO NOT MODIFY. This file was compiled Tue, 12 Jul 2011 16:13:08 GMT from
 * /media/sf_work/pro/ui/app/coffeescripts/forms.coffee
 */

(function() {
    jQuery(function($) {
        return $(document).ready(function() {
            var HelpLinks;
            HelpLinks = {
                helpDivSelector: function(fieldKey) {
                    return ".inline-help[data-field=" + fieldKey + "]";
                },
                position: function() {
                    return $('a.help').each(function() {
                        var $targetLabel, pos, width;
                        $targetLabel = $(this).parent();
                        pos = $targetLabel.offset();
                        width = $targetLabel.width();
                        $(this).css("left", "" + pos.left + "px");
                        return $(this).css("top", "" + pos.top + "px");
                    });
                }
            };
            $('a#advanced-controls').click(function(e) {
                if ($(this).hasClass('show-advanced-controls')) {
                    $(this).html("Hide Advanced Controls");
                    $(this).removeClass('show-advanced-controls');
                    $(this).addClass('hide-advanced-controls');
                    $('a.help').hide();
                    $('fieldset.advanced').slideDown('fast', function() {
                        HelpLinks.position();
                        return $('a.help').show();
                    });
                } else {
                    $(this).html("Show Advanced Controls");
                    $(this).removeClass('hide-advanced-controls');
                    $(this).addClass('show-advanced-controls');
                    $('a.help').hide();
                    $('fieldset.advanced').slideUp('fast', function() {
                        HelpLinks.position();
                        return $('a.help').show();
                    });
                }
                return e.preventDefault();
            });
            $('.inline-help').each(function() {
                var $helpLink, $newHelpLink, $targetLabel, pos, width;
                $helpLink = $(this).children('a');
                $targetLabel = $("#" + ($helpLink.data('field'))).children('label');
                pos = $targetLabel.offset();
                width = $targetLabel.width();
                $targetLabel.prepend($helpLink.clone());
                $newHelpLink = $targetLabel.children('a');
                $newHelpLink.css("left", "" + pos.left + "px");
                $newHelpLink.css("top", "" + pos.top + "px");
                return $helpLink.remove();
            });
            $('a.help').mouseover(function() {
                var $helpDiv, pos, width;
                pos = $(this).offset();
                width = $(this).width();
                $helpDiv = $(HelpLinks.helpDivSelector($(this).data('field')));
                $helpDiv.css("left", "" + (pos.left + width + 5) + "px");
                $helpDiv.css("top", "" + pos.top + "px");
                return $helpDiv.show();
            });
            return $('a.help').mouseout(function() {
                var $helpDiv;
                $helpDiv = $(HelpLinks.helpDivSelector($(this).data('field')));
                return $helpDiv.hide();
            });
        });
    });
}).call(this);
