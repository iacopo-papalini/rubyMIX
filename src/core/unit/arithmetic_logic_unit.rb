class ArithmeticLogicUnit < AbstractUnit
  attr_accessor :eq
  attr_accessor :gt
  attr_accessor :lt
  attr_accessor :overflow

  def initialize(cpu)
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



  # Loads the contents of a memory cell in a register (negates  if needed)
  def load_in_register (instruction)
    op_code, f = extract_op_code_and_modifier(instruction)
    negate = op_code >= Instructions::OP_LDAN
    register = select_register_from_op_code(op_code,
                                            negate ? Instructions::OP_LDAN : Instructions::OP_LDA)
    word = extract_word_from_memory(instruction)
    word.negate if negate
    left, right = explode_f(f)
    register.load_value(word, left, right)
  end


  # Stores the contents of a memory cell in a register (negates  if needed)
  def store_register (instruction)
    op_code, f = extract_op_code_and_modifier(instruction)
    register = select_register_from_op_code(op_code, Instructions::OP_STA)
    word = extract_word_from_memory(instruction)
    left, right = explode_f(f)
    word.store_value(register, left, right)
  end

  def clean_memory(instruction)
    _, f = extract_op_code_and_modifier(instruction)
    word = extract_word_from_memory(instruction)
    left, right = explode_f(f)
    word.store_value(Word.new([0, 0, 0, 0, 0]), left, right)
  end


  # Maps all operations that copy a value directly from the instruction to a register, without reading it from the memory
  # i.e.  INC?, DEC?, ENT?, ENN?
  def write_in_register(instruction)
    op_code, f = extract_op_code_and_modifier(instruction)
    register = select_register_from_op_code(op_code, Instructions::OP_ENTA)
    modified_address = calculate_modified_address(instruction)

    if f == Instructions::F_INCA or f == Instructions::F_DECA
      operation = 'increment_value'
    else
      operation = 'store_long'
    end
    if f == Instructions::F_DECA or f == Instructions::F_ENNA
      modified_address = 0 - modified_address
    end
    register.send(operation, modified_address)
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
