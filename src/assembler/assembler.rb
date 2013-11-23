require 'logger'

class Assembler
  attr_reader :set_memory_locations
  attr_reader :constants
  attr_accessor :location_counter
  attr_accessor :starting_ip
  attr_writer :disassembler
  LINE_REGEXP = /(?<LOC>[A-Z0-9]{1,10})?\s(?<INSTRUCTION>.+)(#(?<REMARKS>.*)\s+)?/

  def initialize
    @parser = InstructionParser.new
    @parser.expression_evaluator = ExpressionParser.new(self)

    # See The Art Of Computer Programming V.1 pag 153
    @constants = {}
    @set_memory_locations = {}
    @location_counter = 0
    @disassembler = nil
    @iterator = nil

    @logger = Logger.new(STDOUT)
    @starting_ip = nil
    @future_references = {}
  end

  class LineIterator
    def initialize(source)
      @lines = source
      @current_line = -1
    end

    def finished?
      return @lines.eof? if (@lines.respond_to? :eof)
      (@current_line >= (@lines.count - 1))
    end

    def next_line_contents
      @current_line += 1
      if @lines.respond_to? :gets
        return @lines.gets
      end
      @lines[@current_line]
    end
  end


  def finished?
    @iterator.finished? or (@starting_ip != nil)
  end


  def parse_lines (lines)
    @iterator = LineIterator.new(lines)

    until finished? do
      parse_next_line
    end
  end


  def load_cpu(mix_core)
    raise 'END statement not yet reached' if @starting_ip == nil
    mix_core.force_instruction_pointer @starting_ip
    set_memory_locations.each do |address, word|
      mix_core.mu.store(address, word)
    end
  end

  def define_constant(name, value)
    @logger.debug('Defining constant  %s=%d' % [name, value])
    @constants[name] = value

    resolve_future_references(name, value)
  end




  def resolve_constant(string)
    string = back_local_reference(string)
    return constants[string] if  @constants.has_key?(string)
    @logger.debug('%s symbol not found, returning future reference' % string)
    FutureReference.new(string)
  end

  def back_local_reference(name)
    (name =~ /^[0-9]B$/) ?  name.sub('B', 'H') :  name
  end

  def parse_line (line, location = @location_counter)
    return [nil, nil] if line[0] =='*'

    @logger.debug 'Parsing line <%s>, location counter: %d' % [line.strip, location]
    parts = LINE_REGEXP.match line
    instruction = @parser.as_instruction (parts['INSTRUCTION'])
    assemble_line(instruction, parts)
  end

  private

  def parse_next_line
    word, defined_symbol = parse_line(@iterator.next_line_contents, @location_counter)
    if word != nil
      set_memory_location(@location_counter, word)
      store_address_in_globals(defined_symbol, @location_counter) if defined_symbol != nil
      @location_counter += 1
    end
  end

  def resolve_future_references(name, value)
    local = name =~ /^[0-9]H$/
    future_reference = local ? name.sub('H', 'F') : name

    override_future_reference_with_local(future_reference, value) if local

    if @future_references.has_key? future_reference
      @logger.debug('Replacing future references for just found symbol %s' % future_reference)

      @future_references[future_reference].each do |entry|
        address, instruction = entry
        @logger.debug('Replacing future at address %d' %address)
        set_memory_locations[address] = instruction.as_word
      end
    end

    delete_local_reference_from_constants(future_reference) if local
  end
  def assemble_line(instruction, parts)
    instruction.execute(self, parts['LOC']) if instruction.class < MetaInstruction
    if instruction.has_future_reference?
      future_reference = instruction.future_reference
      @logger.debug('Adding future reference %s' %future_reference)
      @future_references[future_reference] = [] if !@future_references.has_key? future_reference
      @future_references[future_reference] << [@location_counter, instruction]
      word = Word.new
    else
      word = instruction.as_word
    end
    [word, parts['LOC']]
  end

  def override_future_reference_with_local(future_reference, value)
    @logger.debug('Adding temporary key %s' % future_reference)
    @constants[future_reference] = value
  end

  def delete_local_reference_from_constants(future_reference)
    @logger.debug('Removing temporary ket %s' % future_reference)
    @constants.delete(future_reference)
  end


  def set_memory_location(location, word)
    @set_memory_locations[location] = word
    if @logger.debug?
      @logger.debug 'Set in memory at location %d = %s' %[location, word]
    end

  end

  def store_address_in_globals(global_address, location)
    if global_address != nil
      define_constant(global_address, location)
    end
  end
end