lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "super/version"

Gem::Specification.new do |spec|
  spec.name    = "super"
  spec.version = Super::VERSION
  spec.summary = "https://dev.to/vinistock/creating-ruby-native-extensions-kg1"
  spec.author  = "Following Vinicius Stock tutorial"

  spec.files = Dir.glob("ext/**/*.{c,rb}") + Dir.glob("lib/**/*.rb")

  spec.extensions << "ext/super/extconf.rb"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake-compiler"
end
