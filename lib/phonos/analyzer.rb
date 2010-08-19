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
        if lang
          data[lang] ||= []
          data[lang] << filter(w, lang)
        end
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
        stats[:space] ||= 0
        stats[:total] ||= 0
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

    def calculate data, stats
      f1 = {}
      f2 = {}
      data.each do |lang, words|
        table = @cache.read "#{lang}_phonos"
        unless table
          table = YAML.load_file File.expand_path("../../../share/#{lang}.yaml", __FILE__)
          @cache.write "#{lang}_phonos", table
        end
        words.join('').each_char do |c|
          char = stats[lang][c]
          SCALES.each do |scale|
            f1[scale] ||= 0
            f2[scale] ||= 0
            if table[c]
              if stats[:space] <= 4 && char[:abs] / stats[:total] > 0.368
                f1[scale] += (table[c][scale] * char[:rel] / char[:abs] * (-0.368)) /
                  (table[c][:frequency] * Math.log(table[c][:frequency]))
                f2[scale] += (char[:rel] / char[:abs] * (-0.368)) /
                  (table[c][:frequency] * Math.log(table[c][:frequency]))
              else
                f1[scale] += (table[c][scale] * char[:rel] / stats[:total] *
                  Math.log(char[:abs] / stats[:total])) / (table[c][:frequency] *
                  Math.log(table[c][:frequency]))
                f2[scale] += (char[:rel] / stats[:total] *
                  Math.log(char[:abs] / stats[:total])) / (table[c][:frequency] *
                  Math.log(table[c][:frequency]))
              end
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
    private :calculate
  end
end
