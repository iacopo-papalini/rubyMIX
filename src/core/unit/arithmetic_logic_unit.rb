class ArithmeticLogicUnit < AbstractUnit
  attr_accessor :eq
  attr_accessor :gt
  attr_accessor :lt
  attr_accessor :overflow

  def initialize(cpu)
    # Just to let IntelliJ detect the field, otherwise it keeps complaining
    @cpu = nil
    super(cpu)
    @eq = @gt = @lt = @overflow = @halt = false
  end

  # @param [Word] _ ignored instruction
  def nop (_)

  end

  #adds the value of a memory cell to the accumulator register
  def add_or_sub(instruction)
    op_code, f = extract_op_code_and_modifier(instruction)
    word = extract_word_from_memory(instruction)
    left, right = explode_f(f)
    tmp = @cpu.ra.long.send(op_code == Instructions::OP_ADD ? '+' : '-', word.long(left, right))
    sign = tmp <=> 0
    abs = tmp.abs
    @overflow = true if abs > Limits::MAX_INT
    @cpu.ra.store_long(sign * (abs % Limits::MAX_INT))
  end

  def mul(instruction)
    _, f = extract_op_code_and_modifier(instruction)
    word = extract_word_from_memory(instruction)
    left, right = explode_f(f)
    tmp = @cpu.ra.long * word.long(left, right)
    sign = tmp < 0 ? Sign::NEGATIVE : Sign::POSITIVE
    tmp = tmp.abs
    @cpu.ra.store_long(tmp >> (Limits::BYTES_IN_WORD * Limits::BITS_IN_BYTE))
    @cpu.rx.store_long(tmp % (Limits::MAX_INT + 1))
    @cpu.ra.sign = @cpu.rx.sign = sign
  end


  def less
    [@lt, @eq, @gt] == [true, false, false]
  end

  def equal
    [@lt, @eq, @gt] == [false, true, false]
  end

  def greater
    [@lt, @eq, @gt] == [false, false, true]
  end

  def greater_or_equal
    (@eq or @gt) and not @lt
  end

  def lesser_or_equal
    (@eq or @lt) and not @gt
  end


end
