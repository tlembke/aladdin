require "generators/dresssed/page_generator"

module Dresssed
  module Generators
    class SidenavGenerator < PageGenerator
      view_name "sidenav"

      def set_layout
        controller_const_name = "#{name.camelize}Controller".constantize
        inject_into_class File.join('app/controllers', class_path, "#{file_name}_controller.rb"), controller_const_name, "  layout 'sidenav'\n"
      end
    end
  end
end
