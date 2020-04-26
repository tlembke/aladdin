require "generators/dresssed/handler_support"

module Dresssed
  module Generators
    class PageGenerator < Rails::Generators::NamedBase
      include HandlerSupport

      remove_hook_for :helper
      class_attribute :_view_name, instance_writer: false

      argument :actions, type: :array, required: true, banner: "ACTION",
                             desc: "The action, also the name of the view."

      def create_controller
        invoke :controller, [name, actions], skip: false, skip_routes: false, helper: false, test_framework: false, assets: false, template_engine: false
      end

      def copy_view
        for action in actions do
          view_name = action
          copy_file "views/#{_view_name}.html.#{handler}", "app/views/#{name.underscore}/#{action}.html.#{handler}"
        end
      end

      def self.view_name(name)
        self._view_name = name
        desc "Creates a #{name} page style view under app/views/CONTROLLER/ACTION and its controller."
        source_root File.expand_path('../templates', __FILE__)
      end
    end
  end
end

# Hides this generator. It's only used as a base class.
Rails::Generators.hide_namespace "dresssed:page"
