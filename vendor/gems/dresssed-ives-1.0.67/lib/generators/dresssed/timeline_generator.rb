require "generators/dresssed/page_generator"

module Dresssed
  module Generators
    class TimelineGenerator < PageGenerator
      view_name "timeline"

      def set_layout
        controller_const_name = "#{name.camelize}Controller".constantize
        inject_into_class File.join('app/controllers', class_path, "#{file_name}_controller.rb"), controller_const_name, "  layout 'application'\n"
      end
    end
  end
end
