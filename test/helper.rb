# encoding: utf-8

require 'rubygems'
require 'shoulda'

$: << 'lib'
require 'phonos'

class Phonos::Analyzer
  public :prepare, :detect, :filter, :get_stats
end
