#encoding: utf-8

require 'test/helper'

class TestPhonos < Test::Unit::TestCase
  context "String filtrator" do
    setup do
      @phonos = TestAnalyzer.instance
    end

    should "return prepared string" do
      assert_equal "буба сука ДеБил", @phonos.prepare("  БуБа сука@ ^дебиЛ ")
    end
  end
end