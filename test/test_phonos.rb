# encoding: utf-8

require 'test/helper'

class TestPhonos < Test::Unit::TestCase
  context "Phonos" do
    subject { Phonos::Analyzer.new :ru }

    context '#prepare' do
      should 'return prepared data from raw text' do
        assert_equal({:ru => ["буба", "сука", "ДеБил"]},
          subject.prepare("  БуБа   сука@    ^дебиЛ "))
      end
    end

    context '#detect' do
      should 'detect language correctly' do
        assert_equal :ru, subject.detect('бубаadfd@1*')
        assert_nil subject.detect 'you are crazy faggot'
      end
    end

    context '#filter' do
      should 'correctly filter words' do
        assert_equal 'ДеДюЛя', subject.filter('дедю723%№%ля', :ru)
      end
    end

    context '#get_stats' do
      should 'return correct hash' do
        assert_equal({ :ru =>
              {'б' => { :abs => 2, :rel => 4 }, 'у' => { :abs => 2, :rel => 2 },
              'а' => { :abs => 2, :rel => 2}, 'с' => { :abs => 1, :rel => 3 },
              'к' => { :abs => 1, :rel => 1 }, 'Д' => { :abs => 1, :rel => 3 },
              'е' => { :abs => 1, :rel => 1 }, 'Б' => { :abs => 1, :rel => 1 },
              'и' => { :abs => 1, :rel => 1 }, 'л' => { :abs => 1, :rel => 1 }},
            :space => 2, :total => 13
          }, subject.get_stats({:ru => ["буба", "сука", "ДеБил"]}))
      end
    end

    context '#analyze' do
      should 'return hash' do
        assert subject.analyze("буба сука дебил").kind_of? Hash
      end
    end

    #    context "Counter" do
    #      should "return correct hash" do
    #        assert_equal({
    #          'б' => { :abs => 2, :rel => 4 }, 'у' => { :abs => 2, :rel => 2 },
    #          'а' => { :abs => 2, :rel => 2}, 'с' => { :abs => 1, :rel => 3 },
    #          'к' => { :abs => 1, :rel => 1 }, 'Д' => { :abs => 1, :rel => 3 },
    #          'е' => { :abs => 1, :rel => 1 }, 'Б' => { :abs => 1, :rel => 1 },
    #          'и' => { :abs => 1, :rel => 1 }, 'л' => { :abs => 1, :rel => 1 },
    #          :space => 2, :total => 13 },
    #          subject.get_stats("буба сука ДеБил"))
    #      end
    #    end
  end
end
