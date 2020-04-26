module DropdownHelper
  # +li+ tag with the 'active' class added if the url is the current one.
  # Good for navbar and dropdowns.
  # Eg.:
  #
  #   <%= activatable_li_tag users_path do |url| %>
  #     <%= link_to "Users", url %>
  #   <% end %>
  #
  def activatable_li_tag(url, css_class='', &block)
    css_class = current_page?(url) ? "active #{css_class}" : css_class
    content_tag :li, capture(url, &block), class: css_class
  end

  # +li+ tag with the 'active' class added if the url is the current one with a link
  # inside it pointing to that url.
  # Good for navbar and dropdowns.
  # Eg.:
  #
  #   <%= activatable_li_tag_with_link "Users", users_path %>
  #
  # Same as:
  #
  #   <%= activatable_li_tag users_path do |url| %>
  #     <%= link_to "Users", url %>
  #   <% end %>
  #
  def activatable_li_tag_with_link(title, url, css_class='')
    css_class = current_page?(url) ? "active #{css_class}" : css_class
    content_tag :li, link_to(title, url), class: css_class
  end

  def caret_tag
    content_tag(:span, "", class: "caret")
  end

  def dropdown_menu(title, &block)
    content_tag :li, class: "dropdown" do
      link_to(h(title) + " " + caret_tag, '#',
              'data-toggle' => 'dropdown', class: "dropdown-toggle") +
      content_tag(:ul, class: "dropdown-menu", &block)
    end
  end

  def dropdown_button(title, &block)
    link_to(h(title) + " " + caret_tag, '#',
            'data-toggle' => 'dropdown', class: "btn dropdown-toggle") +
    content_tag(:ul, class: "dropdown-menu", &block)
  end
end
