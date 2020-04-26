require "generators/dresssed/handler_support"

module Dresssed
  module Generators
    class CustomizeGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc "Installs required files to fully customize your Dresssed theme."

      def copy_stylesheet
        copy_file "dresssed.css.scss", "app/assets/stylesheets/dresssed.css.scss"
        copy_file "dresssed.js", "app/assets/javascripts/dresssed.js"
      end

      def add_gem

      end

      def run_bundle
        command = "install"
        say_status :run, "bundle #{command}"
        print `"#{Gem.ruby}" -rubygems "#{Gem.bin_path('bundler', 'bundle')}" #{command}`
      end

      def show_readme
        readme "README_CUSTOMIZE" if behavior == :invoke
      end
    end
  end
end

# Hides this generator under Windows.
Rails::Generators.hide_namespace "dresssed:customize" if RUBY_PLATFORM =~ /mswin|mingw/
