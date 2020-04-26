require "generators/dresssed/handler_support"

module Dresssed
  module Generators
    class LegalPagesGenerator < Rails::Generators::Base
      include HandlerSupport

      source_root File.expand_path('../templates', __FILE__)

      def create_controller
        invoke :controller, [ 'legal' ], skip: true
      end

      desc "Installs the Ives legal pages into the your chosen directory."

      def copy_legal_pages
        ['terms_of_service', 'privacy'].each do |page_name|
          copy_file "views/#{page_name}.html.#{handler}",
                    "app/views/legal/#{page_name}.html.#{handler}"
        end
      end
    end
  end
end
