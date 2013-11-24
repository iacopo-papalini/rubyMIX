require 'core/word'

class Register
  attr_reader :size
  attr_reader :bytes
  attr_accessor :sign
  attr_reader :name
  #noinspection RubyResolve
  include WordFunctions

  def initialize(name, size)
    @size = size
    @name = name
    @bytes = Array.new(size, 0)
    @sign = Sign::POSITIVE
  end

  def ==(another_word)
    self.bytes == another_word.bytes && self.sign==another_word.sign
  end

  def to_s
    'Register %s: %d, %s' % [@name, long, bytes.to_s]
  end
end

class LongRegister < Register
  def initialize(name)
    super(name, 5)
  end
end

class ShortRegister < Register
  def initialize(name)
    super(name, 2)
  end
end

class JumpRegister < ShortRegister
  def initialize
    super ('rj')
  end
  def sign
    Sign::POSITIVE
  end
end
