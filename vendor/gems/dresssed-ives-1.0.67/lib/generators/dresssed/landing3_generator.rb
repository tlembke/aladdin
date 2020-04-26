require "generators/dresssed/page_generator"

module Dresssed
  module Generators
    class Landing3Generator < PageGenerator
      view_name "landing3"

      def set_layout
        controller_const_name = "#{name.camelize}Controller".constantize
        inject_into_class File.join('app/controllers', class_path, "#{file_name}_controller.rb"), controller_const_name, "  layout '_minimal'\n"
      end
    end
  end
end
