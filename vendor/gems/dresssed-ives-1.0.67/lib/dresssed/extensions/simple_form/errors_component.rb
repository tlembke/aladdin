module Dresssed
  module SimpleForm
    # Custom SimpleForm component to render errors with a fancy icon.
    module ErrorTag
      def error_tag(wrapper_options = nil)
        return unless has_errors?
        template.content_tag(:span, template.fa_icon_tag("remove") + " " + error_text, :class => "help-block")
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, Dresssed::SimpleForm::ErrorTag)
