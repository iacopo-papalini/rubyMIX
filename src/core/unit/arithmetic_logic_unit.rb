require 'core/unit/abstract_unit'
class ArithmeticLogicUnit < AbstractUnit
  attr_accessor :eq
  attr_accessor :gt
  attr_accessor :lt
  attr_accessor :overflow

  def initialize(cpu, logger)
    # Just to let IntelliJ detect the field, otherwise it keeps complaining
    @cpu = nil
    @logger = nil
    super(cpu, logger)
    reset
  end

  def reset
    @eq = @gt = @lt = @overflow = false
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

  def div(instruction)
    divisor = extract_word_from_memory(instruction).long
    ra = @cpu.ra.long
    if divisor.abs <= ra.abs
      @overflow = true
      return
    end
    temp = DoubleWord.new(@cpu.ra.bytes + @cpu.rx.bytes)
    temp.sign = @cpu.ra.sign
    temp=temp.long
    @cpu.rx.store_long(@cpu.ra.sign * (temp.abs % divisor))
    @cpu.ra.store_long(temp / divisor)
  end

  def compare(instruction)
    op_code, f = extract_op_code_and_modifier(instruction)
    register = select_register_from_op_code(op_code, Instructions::OP_CMPA)
    word = extract_word_from_memory(instruction)
    left, right = explode_f(f)
    r_value = register.long(left, right)
    m_value = word.long(left, right)
    @lt = r_value < m_value
    @eq = r_value == m_value
    @gt = r_value > m_value
  end

  def shift(instruction)
    _, f = extract_op_code_and_modifier(instruction)
    shift = calculate_modified_address(instruction)
    raise 'Shift value must be non negative' if shift < 0
    @cpu.ra.shift_left(shift) if f == Instructions::F_SLA
    @cpu.ra.shift_right(shift) if f == Instructions::F_SRA
    shift_ra_rx_with_method(:shift_left, shift) if f == Instructions::F_SLAX
    shift_ra_rx_with_method(:shift_right, shift) if f == Instructions::F_SRAX
    shift_ra_rx_with_method(:rotate_left, shift)  if f == Instructions::F_SLC
    shift_ra_rx_with_method(:rotate_right, shift)  if f == Instructions::F_SRC
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

  private

  def shift_ra_rx_with_method(method, shift)
    x_sign = @cpu.rx.sign
    a_sign = @cpu.ra.sign
    (ra, rx) = DoubleWord.from_words(@cpu.ra, @cpu.rx).send(method, shift).split_bytes
    @cpu.ra.load_value(Word.new(a_sign, ra))
    @cpu.rx.load_value(Word.new(x_sign, rx))
  end
end
