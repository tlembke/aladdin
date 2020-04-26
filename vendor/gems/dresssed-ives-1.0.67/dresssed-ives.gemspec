$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dresssed/ives/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dresssed-ives"
  s.version     = Dresssed::Ives::VERSION
  s.authors     = ["Dresssed"]
  s.email       = ["support@dresssed.com"]
  s.homepage    = "http://dresssed.com/themes/ives"
  s.summary     =
  s.description = "Dresssed Ives theme"

  s.files = Dir["{app,config,db,lib,psd}/**/*"] +
            Dir["*.gemspec"] +
            ["CHANGELOG", "LICENSE", "Rakefile", "README.rdoc"]

  s.add_runtime_dependency 'rails', '>= 3.1'
  s.add_runtime_dependency 'jquery-rails'
  s.add_runtime_dependency 'sass-rails'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "version_bumper"
  s.add_development_dependency "aws-sdk"
  s.add_development_dependency "byebug"

  s.post_install_message = <<-DOC
    All done!

    Any questions? Email john@dresssed.com

    Need help? Check out the FAQ first: https://dresssed.com/faq

    Still need help? Go to your order receipt page and send me the information
    requested on the right hand side and send to john@dresssed.com.

  DOC
end
