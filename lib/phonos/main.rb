# encoding: utf-8
$KCODE = 'u'

begin
  require 'active_support/core_ext'
  require 'mathn'
rescue LoadError
  require 'rubygems'
  retry
end
=begin rdoc
Simple phonosemantic analyzer. All rights reserved by Liebermann Inc. and
Sinagoga Ltd.
=end
module Phonos
  require 'singleton'

  SCALES = [
    :good, :big, :gentle, :feminine, :light, :active, :simple, :strong, :hot,
    :fast, :beautiful, :smooth, :easy, :gay, :safe, :majestic, :bright, :rounded,
    :glad, :loud, :long, :brave, :kind, :mighty, :mobile
  ]

=begin rdoc
It's only useful element of this module. Initialization is simple:

@phonos = Phonos::Analyzer.instance

There is no optional parameters, cool features and so on.
And remember to write:

require 'phonos'
=end
  class Analyzer
    include Singleton
    def initialize
      @base = Phonos::Language::RUSSIAN
    end

=begin rdoc
It's only public method of Phonos::Analyzer class. It takes _text_ of (+String+)
and returns +Hash+ of phonosemantic scales for this text. For now is it able to work
only with russian text. All the "left" symbols (including latin alphabet symbols) will
be cutted.

Values of hash are in range from 2 to -2, and this boundary values match maximal
positive and maximal negative value of each scale respectively.

Scale-keys:
  :good, :big, :gentle, :feminine, :light, :active, :simple, :strong, :hot, :fast,
  :beautiful, :smooth, :easy, :gay, :safe, :majestic, :bright, :rounded, :glad,
  :loud, :long, :brave, :kind, :mighty, :mobile
=end
    def analyse text
      @text = prepare text.mb_chars
      process(@text.delete(' '), count(@text))
    end

    def prepare text
      # обрезаем, приводим в нижний регистр, отсекаем нахер лишние символы
      # и выделяем верхним регистром мягкие согласные
      text.strip.downcase.gsub(/[^а-я\s]/, "").gsub(
        /[бвгджзклмнпрстфхцчшщ][еёиьюя]/) { |match| match.mb_chars.capitalize }.gsub(/\s{2,}/, " ")
    end
    private :prepare
    
    def count text
      @counts = {}
      # ищем число вхождений для каждого символа
      # из-за того, что метод String#count отказывается работать как надо,
      # придётся сделать через анус
      text.split(' ').each do |word|
        word.each_char do |c|
          @counts[c] ||= {}
          @counts[c][:abs] ||= 0
          @counts[c][:rel] ||= 0
          @counts[c][:rel] += 1
          @counts[c][:abs] += 1
        end
        @counts[word[0].wrapped_string][:rel] += 2
      end
      @counts[:space] = text.count ' '
      @counts[:total] = text.size - @counts[:space]
      @counts
    end
    private :count

    def process text, counts
      @result = {}
      @f1 = {}
      @f2 = {}
      # и запомните, мои маленькие дэткорщики,- главное - ЕБАШИЛОВО!
      text.each_char do |c|
        SCALES.each do |scale|
          @f1[scale] ||= 0
          @f2[scale] ||= 0
          if counts[:space] <= 4 && counts[c][:abs] / counts[:total] > 0.368
            @f1[scale] += (@base[c][scale] * counts[c][:rel] / counts[c][:abs] * (-0.368)) /
              (@base[c][:frequency] * Math.log(@base[c][:frequency]))
            @f2[scale] += (counts[c][:rel] / counts[c][:abs] * (-0.368)) /
              (@base[c][:frequency] * Math.log(@base[c][:frequency]))
          else
            @f1[scale] += (@base[c][scale] * counts[c][:rel] / counts[:total] *
              Math.log(counts[c][:abs] / counts[:total])) / (@base[c][:frequency] *
              Math.log(@base[c][:frequency]))
            @f2[scale] += (counts[c][:rel] / counts[:total] *
              Math.log(counts[c][:abs] / counts[:total])) / (@base[c][:frequency] *
              Math.log(@base[c][:frequency]))
          end
        end
      end
      SCALES.each do |scale|
        @result[scale] = 3 - @f1[scale] / @f2[scale]
      end
      @result
    end
    private :process
    
  end
end