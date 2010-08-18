# encoding: utf-8
$KCODE='u'

module Phonos
  require 'mathn'

  SCALES = [
    :good, :big, :gentle, :feminine, :light, :active, :simple, :strong, :hot,
    :fast, :beautiful, :smooth, :easy, :gay, :safe, :majestic, :bright, :rounded,
    :glad, :loud, :long, :brave, :kind, :mighty, :mobile
  ]

  PATTERNS = {
    :ru => { :detect => /[а-я]/, :select => [
        [/[^а-я]/, ''],
        [/[бвгджзклмнпрстфхцчшщ][еёиьюя]/, Proc.new { |match| match.mb_chars.capitalize }]
      ] }
  }

  class Analyzer
    def initialize(*args)
      @cache = if args.last.kind_of? ActiveSupport::Cache::Store
        args.pop
      else
        ActiveSupport::Cache.lookup_store :memory_store
      end
      @langs = args.clone
    end

    def analyze raw_text
      data = prepare raw_text
      calculate data, get_stats(data)
    end

    def prepare raw_text
      data = {}
      raw_text.mb_chars.downcase.gsub(/@\w+/, '').split.each do |w|
        lang = detect w
        data[lang] ||= []
        data[lang] << filter(w, lang)
      end
      data
    end
    private :prepare

    def detect word
      @langs.each do |l|
        if word =~ PATTERNS[l][:detect]
          return l
        end
      end
      nil
    end
    private :detect

    def filter w, l
      PATTERNS[l][:select].each do |p|
        if p.last.kind_of? Proc
          w.mb_chars.gsub!(p.first, &p.last)
        else
          w.mb_chars.gsub!(p.first, p.last)
        end
      end
      w.to_s
    end
    private :filter

    def get_stats data
      stats = {}
      data.each do |lang, words|
        string = words.join ' '
        stats[lang] ||= {}
        stats[:space] ||= stats[:total] ||= 0
        stats[:space] += StringCrutch.count(string, ' ')
        stats[:total] += string.mb_chars.size - stats[:space]
        words.each do |word|
          word.chars.to_a.uniq.each do |char|
            stats[lang][char] ||= {}
            stats[lang][char][:abs] ||= 0
            stats[lang][char][:abs] += StringCrutch.count(word, char)
            stats[lang][char][:rel] = stats[lang][char][:abs]
          end
          stats[lang][word.chars.first][:rel] += 2
        end
      end
      stats
    end
    private :get_stats

    #    def analyse raw_text
    #      text = prepare raw_text
    #      counts = count(text)
    #      f1 = {}
    #      f2 = {}
    #      # и запомните, мои маленькие дэткорщики,- главное - ЕБАШИЛОВО!
    #      prepare(text).delete(' ').each_char do |c|
    #        char = counts[c]
    #        SCALES.each do |scale|
    #          f1[scale] ||= 0
    #          f2[scale] ||= 0
    #          if @lang[c]
    #            if counts[:space] <= 4 && char[:abs] / counts[:total] > 0.368
    #              f1[scale] += (@lang[c][scale] * char[:rel] / char[:abs] * (-0.368)) /
    #                (@lang[c][:frequency] * Math.log(@lang[c][:frequency]))
    #              f2[scale] += (char[:rel] / char[:abs] * (-0.368)) /
    #                (@lang[c][:frequency] * Math.log(@lang[c][:frequency]))
    #            else
    #              f1[scale] += (@lang[c][scale] * char[:rel] / counts[:total] *
    #                Math.log(char[:abs] / counts[:total])) / (@lang[c][:frequency] *
    #                Math.log(@lang[c][:frequency]))
    #              f2[scale] += (char[:rel] / counts[:total] *
    #                Math.log(char[:abs] / counts[:total])) / (@lang[c][:frequency] *
    #                Math.log(@lang[c][:frequency]))
    #            end
    #          end
    #        end
    #      end
    #      SCALES.inject({}) do |r, scale|
    #        val = if f1[scale] && f2[scale]
    #          f1[scale] / f2[scale]
    #        else
    #          1.0
    #        end
    #        r[scale] = 3.0 - val
    #        r
    #      end
    #    end
    #
    #    def prepare text
    #      Unicode::downcase(text).strip.
    #        gsub(/[^а-яa-z\s]/, "").
    #        gsub(/[бвгджзклмнпрстфхцчшщ][еёиьюя]/) do |match|
    #        Unicode::capitalize(match)
    #      end.gsub(/\s+/, " ")
    #    end
    #    private :prepare
    #
    #    def count text
    #      counts = {}
    #      # ищем число вхождений для каждого символа
    #      text.split(' ').each do |word|
    #        chars = StringCrutch.chars(word)
    #        chars.each do |char|
    #          counts[char] ||= {}
    #          counts[char][:abs] ||= StringCrutch.count(text, char)
    #          counts[char][:rel] = counts[char][:abs]
    #        end
    #        counts[chars.first][:rel] += 2
    #      end
    #      counts[:space] = StringCrutch.count(text, ' ')
    #      counts[:total] = StringCrutch.size(text) - counts[:space]
    #      counts
    #    end
    #    private :count
  end
end
