/* DO NOT MODIFY. This file was compiled Tue, 12 Jul 2011 16:13:14 GMT from
 * /media/sf_work/pro/ui/app/coffeescripts/jquery-application.coffee
 */

(function() {
  jQuery(function($) {
    return $(document).ready(function() {
      var $topMenu;
      $('ul.drop-menu li.menu').each(function() {
        var max_width;
        max_width = $(this).outerWidth();
        $(this).find('ul.sub-menu li a').each(function() {
          if ($(this).outerWidth() > max_width) {
            return max_width = $(this).outerWidth();
          }
        });
        $(this).css('width', "" + max_width + "px");
        $(this).find('ul.sub-menu li').css('width', "" + (max_width + 15) + "px");
        return $(this).find('ul.sub-menu li.divider').css('width', "" + (max_width - 5) + "px");
      });
      $topMenu = $('#top-menu');
      return $topMenu.css('min-width', $topMenu.outerWidth());
    });
  });
  jQuery(function($) {

  jQuery.ajaxSetup({ 'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} })

  function _ajax_request(url, data, callback, type, method) {
      if (jQuery.isFunction(data)) {
          callback = data;
          data = {};
      }
      return jQuery.ajax({
          type: method,
          url: url,
          data: data,
          success: callback,
          dataType: type
          });
  }

  jQuery.extend({
      put: function(url, data, callback, type) {
          return _ajax_request(url, data, callback, type, 'PUT');
      },
      delete_: function(url, data, callback, type) {
          return _ajax_request(url, data, callback, type, 'DELETE');
      }
  });

  /*
  Submit a form with Ajax
  Use the class ajaxForm in your form declaration
  <% form_for @comment,:html => {:class => "ajaxForm"} do |f| -%>
  */
  jQuery.fn.submitWithAjax = function() {
    this.unbind('submit', false);
    this.submit(function() {
      $.post(this.action, $(this).serialize(), null, "script");
      return false;
    })

    return this;
  };

  /*
  Retreive a page with get
  Use the class get in your link declaration
  <%= link_to 'My link', my_path(),:class => "get" %>
  */
  jQuery.fn.getWithAjax = function() {
    this.unbind('click', false);
    this.click(function() {
      $.get($(this).attr("href"), $(this).serialize(), null, "script");
      return false;
    })
    return this;
  };

  /*
  Post data via html
  Use the class post in your link declaration
  <%= link_to 'My link', my_new_path(),:class => "post" %>
  */
  jQuery.fn.postWithAjax = function() {
    this.unbind('click', false);
    this.click(function() {
      $.post($(this).attr("href"), $(this).serialize(), null, "script");
      return false;
    })
    return this;
  };

  /*
  Update/Put data via html
  Use the class put in your link declaration
  <%= link_to 'My link', my_update_path(data),:class => "put",:method => :put %>
  */
  jQuery.fn.putWithAjax = function() {
    this.unbind('click', false);
    this.click(function() {
      $.put($(this).attr("href"), $(this).serialize(), null, "script");
      return false;
    })
    return this;
  };

  /*
  Delete data
  Use the class delete in your link declaration
  <%= link_to 'My link', my_destroy_path(data),:class => "delete",:method => :delete %>
  */
  jQuery.fn.deleteWithAjax = function() {
    this.removeAttr('onclick');
    this.unbind('click', false);
    this.click(function() {
      if(confirm("Are you sure you want to delete this vuln?")) {
        $.delete_($(this).attr("href"), $(this).serialize(), null, "script");
      }
      return false;
    })
    return this;
  };

  /*
  Ajaxify all the links on the page.
  This function is called when the page is loaded. You'll probaly need to call it again when you write render new datas that need to be ajaxyfied.'
  */
  function ajaxLinks(){
      $('.ajaxForm').submitWithAjax();
      $('a.get').getWithAjax();
      $('a.post').postWithAjax();
      $('a.put').putWithAjax();
      $('a.delete').deleteWithAjax();
  }

  $(document).ready(function() {
  // All non-GET requests will add the authenticity token
   $(document).ajaxSend(function(event, request, settings) {
         if (typeof(window.AUTH_TOKEN) == "undefined") return;
         // IE6 fix for http://dev.jquery.com/ticket/3155
         if (settings.type == 'GET' || settings.type == 'get') return;

         settings.data = settings.data || "";
         settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(window.AUTH_TOKEN);
       });

    ajaxLinks();
  });

});;
}).call(this);
