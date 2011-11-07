page.replace_html :popup_title, @title
page.replace_html :popup_content, :partial => @partial
page.show :popup
