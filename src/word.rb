module Limits
  BITS_IN_BYTE = 6
  BYTES_IN_WORD = 5
  BYTE = 2 ** (BITS_IN_BYTE) - 1
  MAX_INT = 2 ** (BITS_IN_BYTE * BYTES_IN_WORD) - 1
end
module Sign
  POSITIVE = 1
  NEGATIVE = -1
end

module WordFunctions
  def load_value (word, left = 0, right = Limits::BYTES_IN_WORD)
    if left == 0
      @sign = word.sign
      left = 1
    else
      @sign = Sign::POSITIVE
    end
    start = Limits::BYTES_IN_WORD

    while right >= left
      right -= 1
      start -=1
      @bytes[start] = word.bytes[right]
    end
    while start > 0 do
      start -=1
      @bytes[start] =0
    end
    self
  end

  def store_value(word, left = 0, right = Limits::BYTES_IN_WORD)
    if left == 0
      @sign = word.sign
      left = 1
    end

    counter = word.bytes.length
    right.downto(left) do |i|
      counter -= 1
      @bytes[i - 1] = word.bytes[counter]
    end

  end


  def long(left = 0, right = -1)
    if left == 0 && right == -1
      bytes = @bytes
    else
      bytes = Word.new.load_value(self, left, right).bytes
    end
    sign = left == 0 ? @sign : Sign::POSITIVE
    tmp = 0
    self.bytes.length.times do |i|
      tmp += bytes[i] << ((self.bytes.length - i - 1) * Limits::BITS_IN_BYTE)
    end
    (sign == Sign::POSITIVE) ? tmp : -tmp
  end

  def store_long(long)
    @sign = long > 0 ? Sign::POSITIVE : Sign::NEGATIVE
    long = long.abs
    (self.bytes.length - 1).downto 0 do |i|
      @bytes[i] = long % (Limits::BYTE + 1)
      long = long >> Limits::BITS_IN_BYTE
    end
   self
  end

  def increment_value(value)
    store_long(self.long + value)
  end

  def negate
    @sign = (@sign == Sign::POSITIVE) ? Sign::NEGATIVE : Sign::POSITIVE
     self
  end

end

class Word
  attr_reader :bytes
  attr_reader :sign
  include WordFunctions

  def initialize(sign = Sign::POSITIVE, bytes = [0, 0, 0, 0, 0])
    if sign.kind_of?(Array)
      bytes = sign
      sign = Sign::POSITIVE
    end
    @bytes = bytes.map { |a| a & Limits::BYTE }
    @sign = sign
  end

  def ==(another_word)
    self.bytes == another_word.bytes && self.sign==another_word.sign
  end
end