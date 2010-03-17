#encoding: utf-8

require 'rubygems'
require 'shoulda'
require 'lib/phonos'

class TestAnalyzer < Phonos::Analyzer
  def prepare text
    super text
  end
  public :prepare
end