# encoding: utf-8
$KCODE = 'u'

begin
  require 'active_support/core_ext'
rescue LoadError
  require 'rubygems'
  retry
end

module Phonos
  require 'singleton'
  class Analyzer
    include Singleton
    def prepare text
      # обрезаем, приводим в нижний регистр, отсекаем нахер лишние символы
      # и выделяем верхним регистром мягкие согласные
      text.mb_chars.strip.downcase.gsub(/[^а-я\s]/, "").gsub(
        /[бвгджзклмнпрстфхцчшщ][еёиьюя]/) { |match| match.mb_chars.capitalize }
    end
    private :prepare
  end
end