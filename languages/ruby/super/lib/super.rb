require "super/version"
require 'rbconfig'
super_lib = "./super.#{RbConfig::CONFIG['DLEXT']}"
require_relative super_lib


module Super
  class Error < StandardError; end

# This is created via the super.c code
#   class Super
#     def initialize
#       @var = {}
#     end
#   end
end
