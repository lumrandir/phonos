# encoding: utf-8

require 'lib/string_crutch'

begin
  require 'unicode'
  require 'active_support/all'
  require 'yaml'
rescue LoadError
  require 'rubygems'
  retry
end

module Phonos
  require 'lib/phonos/analyzer'
  require 'lib/phonos/language'
end
