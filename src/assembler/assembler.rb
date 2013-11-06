require 'logger'

class Assembler
  attr_reader :set_memory_locations
  attr_reader :constants
  attr_reader :location_counter

  def initialize
    @parser = InstructionParser.new
    @parser.expression_evaluator = ExpressionParser.new(self)

    # See The Art Of Computer Programming V.1 pag 153
    @line_regexp = /(?<LOC>[A-Z0-9]{1,10})?\s(?<INSTRUCTION>.+)(#(?<REMARKS>.*)\s+)?/;
    @constants = {}
    @set_memory_locations = {}
    @location_counter = 0

    @lines = nil
    @current_line = nil
    @logger = Logger.new(STDOUT)
  end

  def parse_lines (lines)
    @current_line = -1
    @lines = lines

    while not_finished? do
      parse_next_line
    end
  end

  def parse_next_line
    @current_line += 1
    instruction, defined_symbol = parse_line(@lines[@current_line], @location_counter)
    if instruction != nil
      set_memory_location(@location_counter, instruction.as_word)
      store_address_in_globals(defined_symbol, @location_counter)if defined_symbol != nil
      @location_counter += 1
    end
  end

  def not_finished?
    @current_line < (@lines.count - 1)
  end

  def parse_line (line, location = @location_counter)
    @logger.debug "Parsing line %s, location counter: %d" % [line, location]
    parts = @line_regexp.match line
    instruction = @parser.as_instruction (parts['INSTRUCTION'])
    if instruction.class == InstructionParser::MetaInstruction
      self.send('execute_meta_instruction_' + instruction.code.downcase, parts, instruction)
      return [nil, nil]
    end
    return [instruction, parts['LOC']]
  end

  def set_memory_location(location, word)
    @set_memory_locations[location] = word
    @logger.debug "Set in memory at location %d = %s" %[location, word]
  end

  def store_address_in_globals(global_address, location)
    if global_address != nil
      @constants[global_address] = location
    end
  end

  def execute_meta_instruction_equ(parts, instruction)
    raise 'Constant name needed for EQU instruction at line %d' % @current_line if parts['LOC'] == nil
    @constants[parts['LOC']] = instruction.value
  end

  def execute_meta_instruction_orig(parts, instruction)
    @location_counter = instruction.value
  end

  def resolve_symbol(string)
    return constants[string] if  @constants.has_key?(string)
    parse_until_symbol_found_or_lines_end(string)

    raise 'Symbol %s not found ' % string if !@constants.has_key? string
    constants[string]
  end

  def parse_until_symbol_found_or_lines_end(string)
    # That's tricky: this method is called recursively by resolve_symbol and _before_ the @location_counter
    # has been increased (see method parse_next_line). So we need to let the parsing skip the current line
    @location_counter += 1
    while !@constants.has_key?(string) and not_finished? do
      parse_next_line
    end
    # See before: now we need to decrease the location counter so that no location is left empty
    @location_counter -= 1
  end
end