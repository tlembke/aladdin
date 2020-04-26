module FormGroupHelper
  class FormGroupBuilder
    def initialize(template, attribute, form)
      @template = template
      @attribute = attribute
      @form = form
    end

    def has_errors?
      @form.object.respond_to?(:errors) && @form.object.errors[@attribute].any?
    end

    # Error message specific to one attribute to be shown inside a control group.
    def error_messages
      if has_errors?
        @template.content_tag :span,
          @template.fa_icon_tag("remove") + " " + @form.object.errors[@attribute].to_sentence,
          :class => "help-block"
      end
    end

    def method_missing(name, *args, &block)
      if @form.respond_to?(name)
        @form.__send__(name, *args, &block)
      else
        super
      end
    end
  end

  module FormBuilderExtensions
    # Return a ControlGroupBuilder that can display error message specific to a single model attribute.
    # Usage inside a FormBuilder:
    #
    #  <%= f.form_group :name do |f| %>
    #    ...
    #    <%= f.error_messages %> <== helper method only accessible inside the control_group block.
    #  <% end %>
    def form_group(attribute, css_error_class='error', &block)
      builder = FormGroupBuilder.new(@template, attribute, self)
      @template.content_tag :div, @template.capture(builder, &block),
                            :class => "form-group #{css_error_class if builder.has_errors?}"
    end
  end
end

ActionView::Helpers::FormBuilder.send(:include, FormGroupHelper::FormBuilderExtensions)