# encoding: utf-8

begin
  require 'unicode_utils'
rescue LoadError
  require 'rubygems'
  retry
end

module Phonos
  require 'phonos/analyzer'
  require 'phonos/language'
end
