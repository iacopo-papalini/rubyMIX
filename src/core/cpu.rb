require 'logger'
require 'core/register'
require 'core/unit/arithmetic_logic_unit'
require 'core/unit/memory_unit'
require 'core/unit/control_unit'
require 'core/unit/i_o_unit'
require 'core/unit/dispatcher'
# Known limits:
# - no floating point operations allowed
# - no I/O

class CPU
  attr_accessor :ra
  attr_accessor :rx
  attr_accessor :ri
  attr_accessor :disassembler
  attr_reader :alu
  attr_reader :cu
  attr_reader :mu
  attr_reader :io
  attr_reader :logger

  INC = 0
  DEC = 1
  ENT = 2
  ENN = 3

  def initialize(logger)
    @logger = logger
    @ra = LongRegister.new(:ra)
    @rx = LongRegister.new(:rx)
    @ri = Array.new(6)
    @ri.length.times do |i|
      @ri[i] = ShortRegister.new('ri%d' %(i+1))
    end

    @disassembler = nil
    @alu = ArithmeticLogicUnit.new(self, @logger)
    @cu = ControlUnit.new(self, @logger)
    @mu = MemoryUnit.new(self, @logger)
    @io = IOUnit.new(self, @logger)
  end

  def clock
    instruction = @mu.fetch(@cu.ip)
    if @logger.debug?
      @logger.debug('Executing instruction at address %s - %s' % [@cu.ip, @disassembler.disassemble(instruction)]) if @disassembler != nil
      @logger.debug('Executing instruction at address %s' % @cu.ip) if @disassembler == nil
    end

    unit, function_name = Dispatcher.new.dispatch(instruction)
    instance_variable_get(unit).send(function_name, instruction)

    @cu.increase_ip
  end


  def change_memory_word(address, new_value)
    @mu.change_memory_word(address, new_value)
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

  def memory_size
    @mu.memory.size
  end

  def bind_io_device(device_id, device_object)
    @io.bind_device(device_id, device_object)
  end

end
