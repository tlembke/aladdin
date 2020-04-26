module IconsHelper
  # Icon from FontAwesome. Use the name without the 'icon-' prefix.
  # Eg.:
  #
  #   <%= fa_icon_tag "remove" %>
  #
  def fa_icon_tag(name)
    content_tag(:i, nil, class: "fa fa-#{name}")
  end

  # Icon from Glyphicon Icons. Use the name without the 'glyphicon glyphicon-' prefix.
  # Eg.:
  #
  #   <%= glyphicon_tag "cloud-download" %>
  #
  def glyphicon_tag(name)
    content_tag(:i, nil, class: "glyphicon glyphicon-#{name}")
  end

  # Icon from Ionicons. Use the name without the 'icon ion-' prefix.
  # Eg.:
  #
  #   <%= ionicon_icon_tag "remove" %>
  #
  def ionicon_icon_tag(name)
    content_tag(:i, nil, class: "icon ion-#{name}")
  end

  # Icon from Material Design Icons.
  # Eg.:
  #
  #   <%= mdi_icon_tag "mdi-action-account-box" %>
  #
  def mdi_icon_tag(name)
    content_tag(:i, name, class: "material-icons")
  end
end
