class Assembler
  attr_reader :set_memory_locations
  attr_reader :constants
  attr_reader :location_counter

  def initialize
    @parser = InstructionParser.new
    @parser.expression_evaluator = ExpressionParser.new(self)

    # TODO split exactly see p. 152
    # See The Art Of Computer Programming V.1 pag 153
    @line_regexp = /(?<LOC>[A-Z0-9]{1,10})?\s(?<INSTRUCTION>.+)(#(?<REMARKS>.*)\s+)?/;
    @constants = {}
    @set_memory_locations = {}
    @location_counter = 0

    @instruction_class = Class.new(Object) do
      attr_reader :as_word

      def initialize(as_word)
        @as_word = as_word
      end
    end

  end

  def parse_line (line)
    parts = @line_regexp.match line
    instruction = @parser.as_instruction (parts['INSTRUCTION'])
    if instruction.class == InstructionParser::MetaInstruction
      self.send('execute_meta_instruction_' + instruction.code, parts, instruction)
    else
      @set_memory_locations[@location_counter]=instruction.as_word
      store_address_in_globals(parts['LOC'])
    end
    @location_counter += 1
  end

  def store_address_in_globals(global_address)
    if global_address != nil
      @constants[global_address] = @location_counter
    end
  end

  def execute_meta_instruction_EQU(parts, instruction)
    raise 'Constant name needed for EQU instruction at line %d' % @current_line if parts['LOC'] == nil
    @constants[parts['LOC']] = instruction.value
  end

  def execute_meta_instruction_ORIG(parts, instruction)
    @location_counter = instruction.value - 1
  end

  def resolve_symbol(string)
    ret =  @constants[string]
    raise 'Symbol %s not found ' % string  if ret == nil
    print "Found value %s for string %s\n" % [ret, string]
    ret
  end
end