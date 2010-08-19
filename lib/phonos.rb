# encoding: utf-8

require 'string_crutch'

begin
  require 'active_support/all'
  require 'yaml'
rescue LoadError
  require 'rubygems'
  retry
end

module Phonos
  require 'phonos/analyzer'
  require 'phonos/language'
end
