# encoding: utf-8

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
It's only public method of Phonos::Analyzer class. It takes _text_ of +String+
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
    def analyse raw_text
      text = prepare raw_text
      counts = count(text)
      f1 = {}
      f2 = {}
      # и запомните, мои маленькие дэткорщики,- главное - ЕБАШИЛОВО!
      prepare(text).delete(' ').each_char do |c|
        char = counts[c]
        SCALES.each do |scale|
          f1[scale] ||= 0
          f2[scale] ||= 0
          if @lang[c]
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
      end
      SCALES.inject({}) do |r, scale|
        val = if f1[scale] && f2[scale]
          f1[scale] / f2[scale]
        else
          1.0
        end
        r[scale] = 3.0 - val
        r
      end
    end

    def prepare text
      # обрезаем, приводим в нижний регистр, отсекаем нахер лишние символы
      # и выделяем верхним регистром мягкие согласные
      Unicode::downcase(text).strip.
        gsub(/[^а-я\s]/, "").
        gsub(/[бвгджзклмнпрстфхцчшщ][еёиьюя]/) do |match|
        Unicode::capitalize(match)
      end.gsub(/\s+/, " ")
    end
    private :prepare

    def count text
      counts = {}
      # ищем число вхождений для каждого символа
      text.split(' ').each do |word|
        chars = StringCrutch.chars(word)
        chars.each do |char|
          counts[char] ||= {}
          counts[char][:abs] ||= StringCrutch.count(text, char)
          counts[char][:rel] = counts[char][:abs]
        end
        counts[chars.first][:rel] += 2
      end
      counts[:space] = StringCrutch.count(text, ' ')
      counts[:total] = StringCrutch.size(text) - counts[:space]
      counts
    end
    private :count
  end
end
