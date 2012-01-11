/* DO NOT MODIFY. This file was compiled Tue, 12 Jul 2011 16:13:12 GMT from
 * /media/sf_work/pro/ui/app/coffeescripts/jquery.table.coffee
 */

(function() {
    var __bind = function(fn, me) {
        return function() {
            return fn.apply(me, arguments);
        };
    };
    jQuery(function($) {
        $.table = {
            defaults: {
                searchInputHint: 'Search',
                sortableClass: 'sortable',
                setFilteringDelay: false,
                datatableOptions: {
                    "bStateSave": true,
                    "oLanguage": {
                        "sSearch": ""
                    },
                    "fnDrawCallback": function() {
                        return $.table.controlBar.buttons.enable();
                    },
                    "sDom": '<"control-bar"f><"list-table-header clearfix"l>t<"list-table-footer clearfix"ip>r',
                    "sPaginationType": "full_numbers"
                }
            },
            checkboxes: {
                bind: function() {
                    return $("table.list thead tr th input[type='checkbox']").live('click', function(e) {
                        var $checkboxes;
                        $checkboxes = $("input[type='checkbox']", "table.list tbody tr td:nth-child(1)");
                        if ($(this).attr('checked')) {
                            return $checkboxes.attr('checked', true);
                        } else {
                            return $checkboxes.attr('checked', false);
                        }
                    });
                }
            },
            controlBar: {
                buttons: {
                    enable: function() {
                        var disable, enable, numChecked;
                        numChecked = $("tbody tr td input[type='checkbox']", "table.list").filter(':checked').size();
                        disable = function($button) {
                            $button.addClass('disabled');
                            return $button.children('input').attr('disabled', 'disabled');
                        };
                        enable = function($button) {
                            $button.removeClass('disabled');
                            return $button.children('input').attr('disabled', '');
                        };
                        switch (numChecked) {
                            case 0:
                                disable($('span.button.single', '.control-bar'));
                                disable($('span.button.multiple', '.control-bar'));
                                return disable($('span.button.any', '.control-bar'));
                            case 1:
                                enable($('span.button.single', '.control-bar'));
                                disable($('span.button.multiple', '.control-bar'));
                                return enable($('span.button.any', '.control-bar'));
                            default:
                                disable($('span.button.single', '.control-bar'));
                                enable($('span.button.multiple', '.control-bar'));
                                return enable($('span.button.any', '.control-bar'));
                        }
                    },
                    bind: function() {
                        var $showButton;
                        $('.control-bar').prepend($('.control-bar-items').html());
                        $showButton = $('span.button a.show', '.control-bar');
                        if ($showButton.length) {
                            return $showButton.click(function(e) {
                                var hostHref;
                                if (!$showButton.parent('span').hasClass('disabled')) {
                                    $("table.list tbody tr td input[type='checkbox']").filter(':checked');
                                    hostHref = $("table.list tbody tr td input[type='checkbox']").filter(':checked').parents('tr').children('td:nth-child(2)').children('a').attr('href');
                                    window.location = hostHref;
                                }
                                return e.preventDefault();
                            });
                        }
                    }
                },
                bind: function() {
                    this.buttons.bind();
                    return $("input[type='checkbox']", "table.list").live('click', __bind(function(e) {
                        return this.buttons.enable();
                    }, this));
                }
            },
            searchField: {
                addInputHint: function(hintText) {
                    var $searchInput;
                    $searchInput = $('.dataTables_filter input');
                    $searchInput.attr('id', 'search');
                    $searchInput.attr('title', hintText);
                    return $searchInput.inputHint({
                        fadeOutSpeed: 300,
                        padding: '2px',
                        paddingLeft: '5px'
                    });
                }
            },
            bind: function($table, options) {
                var $tbody, dataTable;
                $tbody = $table.children('tbody');
                dataTable = null;
                if ($table.hasClass(options.sortableClass)) {
                    if (!$('.control-bar-items').length) {
                        options.datatableOptions["sDom"] = '<"list-table-header clearfix"lfr>t<"list-table-footer clearfix"ip>';
                    }
                    dataTable = $table.dataTable(options.datatableOptions);
                    if (options.setFilteringDelay) {
                        dataTable.fnSetFilteringDelay(500);
                    }
                    $table.data('dataTableObject', dataTable);
                }
                this.checkboxes.bind();
                this.controlBar.bind();
                return this.searchField.addInputHint(options.searchInputHint);
            }
        };
        return $.fn.table = function(options) {
            var $table, settings;
            settings = $.extend(true, {}, $.table.defaults, options);
            $table = $(this);
            return this.each(function() {
                return $.table.bind($table, settings);
            });
        };
    });
}).call(this);
