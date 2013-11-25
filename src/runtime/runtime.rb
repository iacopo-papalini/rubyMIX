require 'assembler/disassembler'
require 'assembler/assembler'
require 'core/cpu'


class Runtime
  def initialize(options)
    logger = Logger.new(STDOUT)
    logger.level = (options[:verbose]) ? Logger::DEBUG : Logger::INFO

    @disassembler = Disassembler.new
    @assembler = Assembler.new
    @cpu = CPU.new(logger)
    @cpu.disassembler = @disassembler
    @assembler.disassembler = @disassembler
    @assembler.logger = logger

    @cpu.bind_io_device(18, STDOUT)

    @last_command = ''

    @execute = options[:execute]
  end

  def run
    if @execute == nil
      interact
    else
      @assembler.parse_lines File.open(@execute, 'r')
      @assembler.load_cpu(@cpu)
      until @cpu.halt do
        @cpu.clock
      end
    end
  end

  private

  def interact
    Readline.completion_append_character=''
    Readline.completion_proc = Proc.new do |str|
      Dir[str+'*'].grep(/^#{Regexp.escape(str)}/)
    end

    while (buf = Readline.readline("> ", true))
      execute_interactive_command(buf)
    end
  end

  def execute_interactive_command(command)
    if command == ''
      command = @last_command
      @cpu.clock
    end
    case command
      when /^load\s+(.+)$/ then
        @assembler.parse_lines File.open($1.strip, 'r')
        print "Loaded %s\n" %$1
        @assembler.load_cpu(@cpu)
      when /^(r[ax])$/ then
        print @cpu.send($1).long.to_s + "\n"
      when /^ri([1-6])$/ then
        print @cpu.ri[$1.to_i - 1].long.to_s + "\n"
      when /^r$/ then
        print "%s\t%s\tgt:%s\teq:%s\tlt:%s\n" %[ @cpu.ra, @cpu.rx, @cpu.alu.gt, @cpu.alu.eq, @cpu.alu.lt]
        6.times do |i|
          print "ri%d: %d\t" %[i+1, @cpu.ri[i].long]
        end
        print "\n"
      when /^next\s+(\d+)$/ then
        $1.to_i.times do |i|
          print (@cpu.ip + i).to_s + "\t" + @disassembler.disassemble(@cpu.mu.memory[@cpu.ip + i]) +"\n"
        end
      when /^dump\s+(\d+):(\d+)$/ then
        print "Dump %s to %s\n" %[$1, $2]
        ($1.to_i..$2.to_i).each do |i|
          print i.to_s + ":\t" + @cpu.mu.memory[i].to_s + "\n"
        end
      when /^long\s+(\d+):(\d+)$/ then
        print "Dump as long %s to %s\n" %[$1, $2]
        ($1.to_i..$2.to_i).each do |i|
          print i.to_s + ":\t" + @cpu.mu.memory[i].long.to_s + "\n"
        end
      when /^code\s+(\d+):(\d+)$/ then
        print "Dump as code %s to %s\n" %[$1, $2]
        ($1.to_i..$2.to_i).each do |i|
          print i.to_s + ":\t" + @disassembler.disassemble(@cpu.mu.memory[i])+ "\n"
        end
      when /^text\s+(\d+):(\d+)$/ then
        print "Dump as text %s to %s\n" %[$1, $2]
        ($1.to_i..$2.to_i).each do |i|
          print i.to_s + ":\t" + @cpu.mu.memory[i].string + "\n"
        end
      when /^run(\s(\d+))?$/ then
        while ($2 == nil or @cpu.ip != $2.to_i) and !@cpu.halt
          @cpu.clock
        end
      when /^debug off$/ then
        @cpu.logger.level = Logger::INFO
      when /^debug on/ then
        @cpu.logger.level = Logger::DEBUG
      else
        print "Unknown command <%s>\n" % command
    end
    @last_command = command
  end
end