# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "super", path: "./super"
  gem "pry-byebug"
  gem "minitest"
end

# https://bundler.io/v1.5/man/gemfile.5.html
# Unlike :git, bundler does not compile C extensions for gems specified as paths.
# So before make
#cd super
#rake compile
#cd ..
#ruby super.rb

require 'minitest'
require "minitest/autorun"

require "super"

class SuperTest < Minitest::Test
  def test_initialize
    puts "I'm super like a rockstart !"
    assert_equal Super::Super.new.var, {}
  end
end
