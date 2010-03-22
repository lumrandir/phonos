# encoding: utf-8
$KCODE = 'u'

begin
  require 'active_support/core_ext'
  require 'mathn'
rescue LoadError
  require 'rubygems'
  retry
end

module Phonos
  require 'singleton'

  SCALES = [
    :good, :big, :gentle, :feminine, :light, :active, :simple, :strong, :hot,
    :fast, :beautiful, :smooth, :easy, :gay, :safe, :majestic, :bright, :rounded,
    :glad, :loud, :long, :brave, :kind, :mighty, :mobile
  ]

  class Analyzer
    include Singleton

    def analyse text
      @text = prepare text.mb_chars
      process(@text, count(@text))
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
      @base = Phonos::Language::RUSSIAN
      text.each_char do |c|
        SCALES.each do |scale|
          if counts[' '][:abs] <= 4
            if counts[c][:abs] / counts[:total] <= 0.368
              @meat = (counts[c][:rel] / counts[c][:abs]) * (
                ((counts[c][:abs] / counts[:total]) * Math.log(counts[c][:abs] / counts[:total])) /
                  @base[c][:frequency] * Math.log(@base[c][:frequency]))
            else
              @meat = (counts[c][:rel] / counts[c][:abs]) * (
                ((counts[c][:abs] / counts[:total]) * Math.log(counts[c][:abs] / counts[:total])) /
                  @base[c][:frequency] * Math.log(@base[c][:frequency]))
            end
              @f1[scale] ||= 0
              @f1[scale] += @base[c][scale] * @meat
              @f2[scale] ||= 0
              @f2[scale] += @meat
            
          else
          end
        end
      end
    end
    private :process
    
  end
end