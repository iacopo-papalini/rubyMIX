class IOUnit < AbstractUnit

  def initialize(cpu, logger)
    # Just to let IntelliJ detect the field, otherwise it keeps complaining
    @cpu = nil
    @logger = nil
    super(cpu, logger)
    @devices = {}
  end

  def bind_device(id, device)
    @devices[id] = device
  end

  def ioc(_)

  end

  def out(instruction)
    _, f = extract_op_code_and_modifier(instruction)
    base = calculate_modified_address(instruction)
    device = @devices[f]
    24.times do |i|
      word = @cpu.mu.fetch(base + i)
      device << word.string
    end
    device << "\n"
  end
end