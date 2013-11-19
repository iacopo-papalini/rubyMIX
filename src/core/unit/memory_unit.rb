class MemoryUnit < AbstractUnit
  attr_accessor :memory

  def initialize(cpu)
    # Just to let IntelliJ detect the field, otherwise it keeps complaining
    @cpu = nil
    super(cpu)

    @memory = Array.new(Limits::MEMORY_SIZE)
    Limits::MEMORY_SIZE.times do |i|
      @memory[i] = Word.new
    end

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


  def change_memory_word(address, new_value)
    @memory[address].load_value(new_value)
  end

  def fetch(address)
    @memory[address]
  end

  def store(address, value)
    @memory[address].store_value(value)
  end

  def extract_word_from_memory(instruction)
    modified_address = calculate_modified_address(instruction)
    @memory[modified_address]
  end
end