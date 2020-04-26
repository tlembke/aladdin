
require "generators/dresssed/handler_support"

module Dresssed
  module Generators
    class FaqPageGenerator < Rails::Generators::Base
      include HandlerSupport

      source_root File.expand_path('../templates', __FILE__)

      def create_controller
        invoke :controller, [ 'faq' ], skip: true
      end

      desc "Installs the Ives faq page into the your chosen directory."

      def copy_faq_page
        ['faq'].each do |page_name|
          copy_file "views/#{page_name}.html.#{handler}",
                    "app/views/faq/#{page_name}.html.#{handler}"
        end
      end
    end
  end
end
