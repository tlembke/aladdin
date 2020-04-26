module Dresssed
  module Ives
    class Engine < ::Rails::Engine
      initializer 'dresssed.setup' do |app|
        app.config.generators.templates << File.join(config.root, "lib/templates")

        # Do not generate stylesheets in code generators, this is what this theme is for.
        app.config.app_generators.stylesheets = false

        # No need to wrap in .field_with_error, fields are wrapped in .form-group.
        ActionView::Base.field_error_proc = Proc.new{ |html_tag, instance| html_tag }
      end

      initializer 'dresssed.sass',
                  :after => 'sass_rails',
                  :group => :all do |app|

          app.config.sass.load_paths << File.join(config.root, "lib", "sass")
          app.config.assets.paths << File.join(config.root, "lib", "sass")
          app.config.assets.paths << File.join(config.root, 'app', 'assets', 'fonts')

          types = [
            '.png',  '.gif', '.jpg', '.jpeg', '.svg', # Images
            '.eot',  '.otf', '.svc', '.woff', '.woff2', '.ttf', # Fonts
          ]

          if Gem::Version.new(::Rails.version) >= Gem::Version.new("5.1.0.rc1")
						Dir.glob(config.root.join('app/assets/*/**/**')) do |assets_directory|
							app.config.assets.precompile += [assets_directory] if File.extname(assets_directory).in? types
						end
					else
						app.config.assets.precompile.push(Proc.new do |path|
							File.extname(path).in? types
						end)
					end
      end

      initializer 'dresssed.will_paginate', :after => 'will_paginate' do
        ActiveSupport.on_load :action_view do
          if defined?(WillPaginate)
            require "dresssed/extensions/will_paginate"
          end
        end
      end

      initializer 'dresssed.simple_form' do
        ActiveSupport.on_load :action_view do
          simple_form_disabled = ENV['DRESSSED_SIMPLE_FORM_DISABLED']
          if defined?(SimpleForm) && !simple_form_disabled
            require "dresssed/extensions/simple_form"
          else
            if simple_form_disabled
              puts "[DRESSSED]  Bypassing simple_form initializer"
            end
          end
        end
      end
    end
  end
end
