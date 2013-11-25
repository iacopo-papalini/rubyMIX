class Dispatcher
  attr_reader :instruction_to_function

  def initialize
    @instruction_to_function = {}
    initialize_alu_functions
    initialize_cu_functions
    initialize_mu_functions
    initialize_io_functions
  end

  def dispatch(instruction)
    op_code = instruction.bytes[4]
    raise "Op-code #{op_code} not found" if @instruction_to_function[op_code] == nil
    @instruction_to_function[op_code]
  end

  private
  def initialize_alu_functions
    @instruction_to_function[Instructions::OP_NOP] = [:@alu, 'nop']
    (Instructions::OP_ADD..Instructions::OP_SUB).each { |op_code| @instruction_to_function[op_code] = [:@alu, 'add_or_sub'] }
    @instruction_to_function[Instructions::OP_MUL] = [:@alu, 'mul']
    @instruction_to_function[Instructions::OP_DIV] = [:@alu, 'div']
    (Instructions::OP_CMPA..Instructions::OP_CMPX).each { |op_code| @instruction_to_function[op_code] = [:@alu, 'compare'] }
    @instruction_to_function[Instructions::OP_SLA] = [:@alu, 'shift']
  end

  def initialize_mu_functions
    (Instructions::OP_LDA..Instructions::OP_LDXN).each { |op_code| @instruction_to_function[op_code] = [:@mu, 'load_in_register'] }
    (Instructions::OP_STA..Instructions::OP_STJ).each { |op_code| @instruction_to_function[op_code] = [:@mu, 'store_register'] }
    @instruction_to_function[Instructions::OP_STZ] = [:@mu, 'clean_memory']
    (Instructions::OP_ENTA..Instructions::OP_ENTX).each { |op_code| @instruction_to_function[op_code] = [:@mu, 'write_in_register'] }
    @instruction_to_function[Instructions::OP_MOVE] = [:@mu, 'move']
  end

  def initialize_cu_functions
    @instruction_to_function[Instructions::OP_HLT] = [:@cu, 'generic_operation']
    @instruction_to_function[Instructions::OP_JMP] = [:@cu, 'jump']
    (Instructions::OP_JAN..Instructions::OP_JXNP).each { |op_code| @instruction_to_function[op_code] = [:@cu, 'jump_check_register'] }
  end

  def initialize_io_functions
    @instruction_to_function[Instructions::OP_IOC] = [:@io, 'ioc']
    @instruction_to_function[Instructions::OP_OUT] = [:@io, 'out']

  end
end
