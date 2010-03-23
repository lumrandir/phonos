# encoding: utf-8

begin
  require 'active_support/core_ext'
rescue LoadError
  require 'rubygems'
  retry
end

module Phonos
  require 'phonos/main'
  require 'phonos/language'
end
