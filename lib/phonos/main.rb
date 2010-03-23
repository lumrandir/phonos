# encoding: utf-8
$KCODE = 'u'

=begin rdoc
  Simple phonosemantic analyzer.
  All rights reserved by Liebermann Inc. and Sinagoga Ltd.
  Developed by Konstantin "Lumren Randir" Lukinskih.
=end
module Phonos
  require 'singleton'
  require 'mathn'

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
      @lang = Phonos::Language::RUSSIAN
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
      counts = count(text.mb_chars)
      f1 = {}
      f2 = {}
      # и запомните, мои маленькие дэткорщики,- главное - ЕБАШИЛОВО!
      prepare(text.mb_chars).delete(' ').each_char do |c|
        char = counts[c]
        SCALES.each do |scale|
          f1[scale] ||= 0
          f2[scale] ||= 0
          if counts[:space] <= 4 && char[:abs] / counts[:total] > 0.368
            f1[scale] += (@lang[c][scale] * char[:rel] / char[:abs] * (-0.368)) /
              (@lang[c][:frequency] * Math.log(@lang[c][:frequency]))
            f2[scale] += (char[:rel] / char[:abs] * (-0.368)) /
              (@lang[c][:frequency] * Math.log(@lang[c][:frequency]))
          else
            f1[scale] += (@lang[c][scale] * char[:rel] / counts[:total] *
              Math.log(char[:abs] / counts[:total])) / (@lang[c][:frequency] *
              Math.log(@lang[c][:frequency]))
            f2[scale] += (char[:rel] / counts[:total] *
              Math.log(char[:abs] / counts[:total])) / (@lang[c][:frequency] *
              Math.log(@lang[c][:frequency]))
          end
        end
      end
      SCALES.inject({}) do |r, scale|
        r[scale] = 3.0 - f1[scale] / f2[scale]
        r
      end
    end

    def prepare text
      # обрезаем, приводим в нижний регистр, отсекаем нахер лишние символы
      # и выделяем верхним регистром мягкие согласные
      text.strip.downcase.
        gsub(/[^а-я\s]/, "").
        gsub(/[бвгджзклмнпрстфхцчшщ][еёиьюя]/) do |match|
          match.mb_chars.capitalize
        end.gsub(/\s{2,}/, " ")
    end
    private :prepare

    def count text
      counts = {}
      # ищем число вхождений для каждого символа
      # из-за того, что метод String#count отказывается работать как надо,
      # придётся сделать через анус
      text.split(' ').each do |word|
        word.each_char do |c|
          counts[c] ||= {}
          counts[c][:abs] ||= 0
          counts[c][:rel] ||= 0
          counts[c][:rel] += 1
          counts[c][:abs] += 1
        end
        counts[word[0].wrapped_string][:rel] += 2
      end
      counts[:space] = text.count ' '
      counts[:total] = text.size - counts[:space]
      counts
    end
    private :count
  end
end
