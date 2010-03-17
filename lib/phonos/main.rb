# encoding: utf-8
$KCODE = 'u'

begin
  require 'active_support/core_ext'
  require 'pp'
rescue LoadError
  require 'rubygems'
  retry
end

module Phonos
  require 'singleton'
  class Analyzer
    include Singleton

    def analyse text
      @text = text.mb_chars
      count(prepare(@text))
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
      text.each_char do |sym|
        @counts[sym] ||= {}
        @counts[sym][:abs] ||= 0
        @counts[sym][:rel] ||= 0
        @counts[sym][:abs] += 1
        if @prev == ' ' || !@prev
          @counts[sym][:rel] += 3
        else
          @counts[sym][:rel] += 1
        end
        @prev = sym
      end
      @counts[:total] = text.size - @counts[' '][:abs]
      @counts
    end
    private :count
    
  end
end