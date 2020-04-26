require "generators/dresssed/handler_support"

module Dresssed
  module Generators
    class ErrorPagesGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates/error_pages', __FILE__)

      desc "Installs the Ives error pages into the /public directory."

      def copy_stylesheet
        copy_file "403.html", "public/403.html"
        copy_file "404.html", "public/404.html"
        copy_file "422.html", "public/422.html"
        copy_file "500.html", "public/500.html"
      end
    end
  end
end
