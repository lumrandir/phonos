$KCODE = 'u' if RUBY_VERSION < '1.9'

module StringCrutch
  class << self
    def count(str, char)
      chars(str).select { |c| c == char }.size
    end

    def size(str)
      chars(str).size
    end

    def chars(str)
      str.scan(/./mu)
    end
  end
end
