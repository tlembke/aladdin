module Dresssed
  module Generators
    module HandlerSupport
      extend ActiveSupport::Concern
      
      included do
        class_option :template_engine
      end
      
      protected
        def handler
          handler = options[:template_engine].to_s.gsub('erubis', 'erb')
          handler = 'erb' unless %w(erb haml).include?(handler) # Default to ERB if handler is unsupported
          handler
        end
      
    end
  end
end