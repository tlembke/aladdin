require "generators/dresssed/handler_support"

module Dresssed
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include HandlerSupport

      source_root File.expand_path('../templates', __FILE__)

      desc "Installs the Dresssed theme in your application."

      def copy_layouts
        layouts_path = "app/views/layouts"
        %w( _base _flashes _footer _navbar application home sidenav _sidenav _minimal _centered email ).each do |name|
          copy_file "layouts/#{name}.html.#{handler}", "#{layouts_path}/#{name}.html.#{handler}"
        end
        template "layouts/_user_nav.html.#{handler}", "#{layouts_path}/_user_nav.html.#{handler}"
      end

      def copy_stylesheet
        copy_file "dresssed.css", "app/assets/stylesheets/dresssed.css"
      end

      def add_jquery_to_gemfile
        return unless Gem::Version.new(::Rails.version) >= Gem::Version.new("5.1.0.rc1")
        say_status :info, "Adding jQuery back into the Gemfile"
        gem "jquery-rails"
        system('bundle install')
      end

      def add_jquery_require_to_app_js
        return unless Gem::Version.new(::Rails.version) >= Gem::Version.new("5.1.0.rc1")
        sentinel = "= require rails-ujs"

        file = 'app/assets/javascripts/application.js'

        # Plain JS
        if File.file?(file)
          inject_into_file file, "\n//= require jquery\n", { :before => "//#{sentinel}" }
          inject_into_file file, "//= require jquery_ujs\n", { :before => "//#{sentinel}" }
        # CoffeeScript
        elsif File.file?("#{file}.coffee")
          inject_into_file "#{file}.coffee", "\n#require jquery\n", { :before => "##{sentinel}" }
          inject_into_file "#{file}.coffee", "#require jquery_ujs\n", { :before => "##{sentinel}" }
        # No main JS file
        else
          say_status :warning, "Can't find #{file}. " +
            "Make sure to include add `require dresssed` in your Javascript.", :red
        end
      end

      def require_dresssed_javascript
        sentinel = "= require jquery_ujs"
        code = "= require dresssed"

        file = 'app/assets/javascripts/application.js'
        # Plain JS
        if File.file?(file)
          inject_into_file file, "\n//#{code}", { :after => "//#{sentinel}" }
        # CoffeeScript
        elsif File.file?("#{file}.coffee")
          inject_into_file "#{file}.coffee", "\n##{code}", { :after => "##{sentinel}" }
        # No main JS file
        else
          say_status :warning, "Can't find #{file}. " +
            "Make sure to include add `require dresssed` in your Javascript.", :red
        end
      end

      def add_app_name_to_application_helper
        sentinel = "module ApplicationHelper\n"
        code = <<END
  def app_name
    "My App"
  end
END

        file = 'app/helpers/application_helper.rb'
        create_file file, "module ApplicationHelper\nend" unless File.file?(file)
        inject_into_file file, code, { :after => sentinel }
      end

      def copy_favicons_into_asset_pipeline
        return unless Gem::Version.new(::Rails.version) >= Gem::Version.new("5.1.0.rc1")
        copy_file Rails.root.join('public', 'favicon.ico'), Rails.root.join('app', 'assets', 'images', 'favicon.ico')
      end

      def show_readme
        readme_template "README.tt" if behavior == :invoke
      end

      protected
        def devise?
          defined?(Devise)
        end

        # Can't fully cutomize theme under Windows because of less.rb dep on therubyracer.
        def can_customize?
          RUBY_PLATFORM !~ /mswin|mingw/
        end

        def readme_template(file)
          source = File.binread(find_in_source_paths(file))
          log ERB.new(source, nil, '-', '@output_buffer').result(binding)
        end
    end
  end
end
