# encoding: utf-8

require 'string_crutch'

begin
  require 'unicode'
rescue LoadError
  require 'rubygems'
  retry
end

module Phonos
  require 'phonos/analyzer'
  require 'phonos/language'
end
