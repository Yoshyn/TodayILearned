# frozen_string_literal: true

begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'
  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem 'rack'
  gem 'webrick'
  gem 'json'
end

require 'rack'
load 'application.rb'

# For a full list of options, see
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/webrick/rdoc/WEBrick.html
options = {
  Host: '0.0.0.0', # Important : Binding on all interface
  Port: '8080'
}

Rack::Handler::WEBrick.run(Application, **options) do |server|
  [:INT, :TERM].each { |sig| trap(sig) { server.stop } }
end
