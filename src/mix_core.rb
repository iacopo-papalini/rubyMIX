# Known limits:
# - no floating point operations allowed
# - no I/O

class MixCore
  attr_reader :ra
  attr_reader :rx
  attr_reader :rj
  attr_reader :ri
  attr_accessor :eq
  attr_accessor :gt
  attr_accessor :lt
  attr_reader :memory
  attr_accessor :overflow
  attr_accessor :ip

  INC = 0
  DEC = 1
  ENT = 2
  ENN = 3

  def initialize
    @ra = Register::Big.new
    @rx = Register::Big.new
    @rj = Register::Jump.new
    @ri = Array.new(6, Register::Small.new)
    @eq = @gt = @lt = @overflow = false
    @memory = Array.new(Limits::MEMORY_SIZE)
    Limits::MEMORY_SIZE.times do |i|
      @memory[i] = Word.new
    end
    @ip = 0

    @instruction_to_function = {0 => 'nop'}
    (Instructions::OP_ADD..Instructions::OP_SUB).each { |op_code| @instruction_to_function[op_code] = 'add_or_sub' }
    (Instructions::OP_LDA..Instructions::OP_LDXN).each { |op_code| @instruction_to_function[op_code] = 'load_in_register' }
    (Instructions::OP_STA..Instructions::OP_STJ).each { |op_code| @instruction_to_function[op_code] = 'store_register' }
    @instruction_to_function[Instructions::OP_STZ] = 'clean_memory'
    @instruction_to_function[Instructions::OP_JMP] = 'jump'
    (Instructions::OP_JAN..Instructions::OP_JXNP).each { |op_code| @instruction_to_function[op_code] = 'jump_check_register' }
    (Instructions::OP_ENTA..Instructions::OP_ENTX).each { |op_code| @instruction_to_function[op_code] = 'write_in_register' }
  end

  def clock
    # @var Word
    instruction = @memory[@ip]
    op_code, _ = extract_op_code_and_modifier(instruction)

    function_name = @instruction_to_function[op_code]
    if function_name == nil then
      raise "Op-code #{op_code} not found"
    end
    send(function_name, instruction)

    @ip = (@ip + 1) % @memory.size
  end

  def extract_op_code_and_modifier(instruction)
    return instruction.bytes[4], instruction.bytes[3]
  end

  def change_memory_word(address, new_value)
    @memory[address].load_value(new_value)
  end

  # @param [Word] _ ignored instruction
  def nop (_)

  end

  #adds the value of a memory cell to the accumulator register
  def add_or_sub(instruction)
    op_code, f = extract_op_code_and_modifier(instruction)
    word = extract_word_from_memory(instruction)
    left, right = explode_f(f)
    tmp = @ra.long.send(op_code == Instructions::OP_ADD ? '+' : '-', word.long(left, right))
    sign = tmp <=> 0
    abs = tmp.abs
    @overflow = true if abs > Limits::MAX_INT
    @ra.store_long(sign * (abs % Limits::MAX_INT))
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

  def jump(instruction)
    _, f = extract_op_code_and_modifier(instruction)
    address = calculate_modified_address(instruction)

    skip = should_perform_jump_operation(f) ? false : true

    return if skip
    perform_jump(address, f != 1) # since ip gets increased every clock
  end

  def perform_jump(address, update_rj)
    @rj.store_long(@ip + 1) if update_rj
    @ip = address - 1
  end

  def should_perform_jump_operation(f)
    return false if (f == Instructions::F_JOV and @overflow == false)
    return false if (f == Instructions::F_JNOV and @overflow == true)
    return false if (f == Instructions::F_JL and !less)
    return false if (f == Instructions::F_JE and !equal)
    return false if (f == Instructions::F_JG and !greater)
    return false if (f == Instructions::F_JGE and !greater_or_equal)
    return false if (f == Instructions::F_JNE and equal)
    return false if (f == Instructions::F_JLE and !lesser_or_equal)

    true
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


  def extract_word_from_memory(instruction)
    modified_address = calculate_modified_address(instruction)
    @memory[modified_address]
  end

  def calculate_modified_address(instruction)
    i = instruction.bytes[2]
    modified_address = instruction.long(0, 2)
    modified_address + ((i > 0) ? @ri[i-1].long : 0)
  end

  def explode_f(f)
    left = f / 8
    right = f % 8
    return left, right
  end

  def select_register_from_op_code(op_code, base)
    index = op_code - base
    case index
      when 0
        register = @ra
      when 1..6
        register = @ri[index - 1]
      when 7
        register = @rx
      when 8
        register = @rj
      else
        raise 'Cannot select register from index %d' % index
    end
    register
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
