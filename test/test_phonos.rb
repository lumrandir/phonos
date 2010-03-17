#encoding: utf-8
$KCODE = 'u'

require 'test/helper'

class TestPhonos < Test::Unit::TestCase
  context "Phonos" do
    setup do
      @phonos = TestAnalyzer.instance
    end
    
    context "String filtrator" do
      should "return prepared string" do
        assert_equal "буба сука ДеБил".mb_chars, @phonos.prepare("  БуБа   сука@    ^дебиЛ ".mb_chars)
      end
    end

    context "Counter" do
      should "return correct hash" do
        assert_equal({ 'б' => { :abs => 2, :rel => 4 }, 'у' => { :abs => 2, :rel => 2 },
            'а' => { :abs => 2, :rel => 2}, 'с' => { :abs => 1, :rel => 3 },
            'к' => { :abs => 1, :rel => 1 }, 'Д' => { :abs => 1, :rel => 3 },
            'е' => { :abs => 1, :rel => 1 }, 'Б' => { :abs => 1, :rel => 1 },
            'и' => { :abs => 1, :rel => 1 }, 'л' => { :abs => 1, :rel => 1 },
            ' ' => { :abs => 2, :rel => 2 }, :total => 13
          }, @phonos.count("буба сука ДеБил".mb_chars))
      end
    end
  end
end