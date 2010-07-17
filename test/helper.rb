# encoding: utf-8

require 'rubygems'
require 'shoulda'

$: << 'lib'
require 'phonos'

class Phonos::Analyzer
  public :prepare, :count
end
