#encoding: utf-8
$KCODE = 'u'
require 'rubygems'
require 'pp'
require 'active_support/core_ext'


keys = [:good, :big, :gentle, :feminine, :light, :active, :simple, :strong, :hot,
  :fast, :beautiful, :smooth, :easy, :gay, :safe, :majestic, :bright, :rounded,
  :glad, :loud, :long, :brave, :kind, :mighty, :mobile
]

File.open("lib/phonos/hardcode.rb", "w") do |f|
  f.puts "module Hardcode"
  f.puts "def get_hash(sym)"
  f.puts "case"
  File.open("crap.txt", "r") do |crap|
    crap.gets
    while line = crap.gets
      key = line.scan(/../).first
      if key[-1] == 9
        key.chop!
      elsif key[-1] == 39 || key[-1] == 92
        key = key.mb_chars.chop.upcase
      end
      f.puts "when sym == \'#{key}\'"
      fields = line.scan(/[0-9]\.[0-99]/)
      frequency = line.scan(/0\.[0-9][0-9][0-9]/).first.to_f
      fields.delete_at(-1)
      f.puts "{"
      fields.each_with_index do |k, i|
        f.print ":#{keys[i]} => #{k}, "
      end
      f.puts ":frequency => #{frequency}"
      f.puts "}"
    end
  end
  f.puts "else"
  f.puts "nil"
  f.puts "end"
  f.puts "end"
  f.puts "end"
end
