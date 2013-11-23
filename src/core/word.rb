#encoding: UTF-8
module Limits
  BITS_IN_BYTE = 6
  BYTES_IN_WORD = 5
  BYTE = 2 ** (BITS_IN_BYTE) - 1
  MAX_INT = 2 ** (BITS_IN_BYTE * BYTES_IN_WORD) - 1
  MEMORY_SIZE = 4000
end
module Sign
  POSITIVE = 1
  NEGATIVE = -1
end

module WordFunctions
  CHARACTERS = " ABCDEFGHI∆JKLMONPQR∑∏STUVWXYZ0123456789.,()+-*/=$<>@;:'"

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
    left = set_sign_for_store(left, word.sign)
    first_byte_to_copy = [left, Limits::BYTES_IN_WORD - word.bytes.length + 1].max

    copy_bytes(first_byte_to_copy, right, word)
    set_zero_for_short_word(first_byte_to_copy, left)
  end

  def set_zero_for_short_word(first_byte_to_copy, left)
    (first_byte_to_copy-1).downto(left) do |i|
      @bytes[i - 1] = 0
    end
  end

  def copy_bytes(first_byte_to_copy, right, word)
    counter = word.bytes.length
    right.downto(first_byte_to_copy) do |i|
      counter -= 1
      @bytes[i - 1] = word.bytes[counter]
    end
  end

  def set_sign_for_store(left, sign)
    if left == 0
      @sign = sign
      left = 1
    end
    left
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
    @sign = long >= 0 ? Sign::POSITIVE : Sign::NEGATIVE
    long = long.abs
    (self.bytes.length - 1).downto 0 do |i|
      @bytes[i] = long % (Limits::BYTE + 1)
      long = long >> Limits::BITS_IN_BYTE
    end
   self
  end

  def string
    ret = ''
    bytes.each do |byte|
      ret += CHARACTERS[byte]
    end
    ret
  end
  def store_string(string)
    (self.bytes.length - 1).downto 0 do |i|
      @bytes[i] = CHARACTERS.index(string[i])
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

  def to_s
    self.class.to_s + ': ' + @sign.to_s + ' ' +@bytes.to_s
  end

  def as_word
    self
  end
end

class Word
  attr_reader :bytes
  attr_accessor :sign
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
    return false if another_word == nil
    self.bytes == another_word.bytes && self.sign==another_word.sign
  end


end

class DoubleWord
  attr_reader :bytes
  attr_accessor :sign
  include WordFunctions

  def initialize(sign = Sign::POSITIVE, bytes = [0,0,0,0,0,0, 0, 0, 0, 0])
    if sign.kind_of?(Array)
      bytes = sign
      sign = Sign::POSITIVE
    end
    @bytes = bytes.map { |a| a & Limits::BYTE }
    @sign = sign
  end

  def ==(another_word)
    return false if another_word == nil
    self.bytes == another_word.bytes && self.sign==another_word.sign
  end

end