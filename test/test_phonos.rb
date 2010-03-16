#encoding: utf-8

require 'rubygems'
require 'shoulda'
require 'lib/phonos'

class TestPhonos < Test::Unit::TestCase
  context "Unprepared string" do
    setup do
      @phonos = Phonos::Analyzer.instance
    end

    should "return prepared string" do
      assert_equal "буба сука ДеБил", @phonos.prepare("  БуБа сука@ ^дебиЛ ")
    end
  end
end