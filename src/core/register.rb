class Register
  attr_reader :size
  attr_reader :bytes
  attr_accessor :sign
  #noinspection RubyResolve
  include WordFunctions

  def initialize(size)
    @size = size
    @bytes = Array.new(size, 0)
    @sign = Sign::POSITIVE
  end

  def ==(another_word)
    self.bytes == another_word.bytes && self.sign==another_word.sign
  end
end

class LongRegister < Register
  def initialize
    super 5
  end
end

class ShortRegister < Register
  def initialize
    super 2
  end
end

class JumpRegister < ShortRegister
  def sign
    Sign::POSITIVE
  end
end
