#encoding: utf-8

require 'rubygems'
require 'shoulda'
require 'lib/phonos'
require 'active_support/core_ext'

class TestAnalyzer < Phonos::Analyzer
  def prepare text
    super text
  end

  def count text
    super text
  end
  public :prepare, :count
end