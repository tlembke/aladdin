module EmailTemplateHelper
  extend ActiveSupport::Concern

  # Ok, some madness ahead. There seems to be a bug in rails as documented http://www.candland.net/2012/04/17/rails-routes-used-in-an-isolated-engine/ where including the URL helpers will cause all other
  # path helpers to go crazy. So instead of include Rails.application.routes.url_helpers
  # we specifically respond to path and url helpers in the method_missing and proxy them up to the
  # main_app if they exist. This way the email helpers in the devise templates will still work.

  def method_missing method, *args, &block
    method.to_s.end_with?('_path', '_url') and main_app.respond_to?(method) ? main_app.send(method, *args) : super
  end

  def email_message_spacer( count=1 )
    (1..count).each do
      return capture do
        concat content_tag(:br)
      end
    end
  end

  def email_message_body_text &block
    content_tag(:span, capture(&block), style: "font-family: Avenir, 'Helvetica Neue', Helvetica, sans-serif; font-size:28px; color:#444444;")
  end

  def email_message_small_text &block
    content_tag(:span, capture(&block), style: "font-family: Avenir, 'Helvetica Neue', Helvetica, sans-serif; font-size:22px; color:#444444;")
  end

  def email_message_button &block
    content_tag(:table, border: 0, cellpadding: 0, cellspacing: 0, width: "50%", style: "background-color:#16A086;") do
      content_tag(:tr) do
        concat(email_message_spacer(4))
        concat( content_tag(:td, nil, style: "padding: 18px 20px 18px 20px; font-family:  Avenir, 'Helvetica Neue', Helvetica, sans-serif, sans-serif; color: #ffffff; font-size: 18px; text-align: center;") do
          content_tag(:span, capture(&block), style: "text-decoration: none; color: #ffffff;")
        end)
      end
    end
  end

  def email_message_section &block
    content_tag(:tr) do
      content_tag(:td) do
        content_tag(:table, border: 0, cellpadding: 0, cellspacing: 0, width: "100%") do
          content_tag(:tr) do
            content_tag(:td, align: "center", valign: "top") do
              content_tag(:table, border: 0, cellpadding: 10, cellspacing: 0, width: "100%") do
                content_tag(:tr) do
                  content_tag(:td, capture(&block), align: "center", valign: "top")
                end
              end
            end
          end
        end
      end
    end
  end
end
