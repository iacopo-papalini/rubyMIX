# Known limits:
# - no floating point operations allowed
# - no I/O

class CPU
  attr_accessor :ra
  attr_accessor :rx
  attr_accessor :ri
  attr_accessor :memory
  attr_accessor :disassembler
  attr_reader :alu
  attr_reader :cu

  INC = 0
  DEC = 1
  ENT = 2
  ENN = 3

  def initialize
    @logger = Logger.new(STDOUT)
    @ra = LongRegister.new
    @rx = LongRegister.new
    @ri = Array.new(6)
    @ri.length.times do |i|
      @ri[i] = ShortRegister.new
    end
    @memory = Array.new(Limits::MEMORY_SIZE)
    Limits::MEMORY_SIZE.times do |i|
      @memory[i] = Word.new
    end

    @disassembler = nil
    @alu = ArithmeticLogicUnit.new(self)
    @cu = ControlUnit.new(self)

  end

  def clock
    instruction = @memory[@cu.ip]
    if @logger.debug?
      @logger.debug('Executing instruction at address %s - %s' % [@cu.ip, @disassembler.disassemble(instruction)]) if @disassembler != nil
      @logger.debug('Executing instruction at address %s' % @cu.ip) if @disassembler == nil
    end

    unit, function_name = Dispatcher.new.dispatch(instruction)
    instance_variable_get(unit).send(function_name, instruction)

    @cu.increase_ip
   end


  def change_memory_word(address, new_value)
    @memory[address].load_value(new_value)
  end

  def ip
    @cu.ip
  end


  def force_instruction_pointer(ip)
    @cu.ip=ip
  end

  def rj
    @cu.rj
  end

  def halt
    @cu.halt
  end
end
