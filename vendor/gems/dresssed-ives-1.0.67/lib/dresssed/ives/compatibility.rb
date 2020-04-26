module Dresssed
  def self.key_value(key, value)
    if RUBY_VERSION < '1.9'
      ":#{key} => #{value}"
    else
      "#{key}: #{value}"
    end
  end
end