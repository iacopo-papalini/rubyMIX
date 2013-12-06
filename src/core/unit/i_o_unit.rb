require 'core/unit/abstract_unit'
require 'devices'
class IOUnit < AbstractUnit

  def initialize(cpu, logger)
    # Just to let IntelliJ detect the field, otherwise it keeps complaining
    @cpu = nil
    @logger = nil
    super(cpu, logger)
    @devices = {}
  end

  def bind_device(id, first_stream, second_stream)
    the_class = Devices.const_get(Ports::PORTS[id])

    @devices[id] = the_class.new(first_stream) unless the_class::WRITE
    @devices[id] = the_class.new(first_stream) unless the_class::READ
    @devices[id] = the_class.new(first_stream, second_stream) if the_class::READ && the_class::WRITE

  end

  def ioc(_)

  end

  def out(instruction)
    _, f = extract_op_code_and_modifier(instruction)
    base = calculate_modified_address(instruction)
    device = @devices[f]
    device.write(@cpu.mu, base)
  end

  def in(instruction)
    _, f = extract_op_code_and_modifier(instruction)
    base = calculate_modified_address(instruction)
    device = @devices[f]
    device.read(@cpu.mu, base)
  end
end