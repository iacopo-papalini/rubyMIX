require 'assembler/disassembler'
require 'assembler/assembler'
require 'core/cpu'


class Runtime
  def initialize
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    @disassembler = Disassembler.new
    @assembler = Assembler.new
    @cpu = CPU.new(logger)
    @cpu.disassembler = @disassembler
    @assembler.disassembler = @disassembler
    @assembler.logger = logger

    @cpu.bind_io_device(18, STDOUT)

    @last_command = ''
  end

  def execute(command)
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
      when /^next\s+(\d+)$/ then
        $1.to_i.times do |i|
          print (@cpu.ip + i).to_s + "\t" + @disassembler.disassemble(@cpu.mu.memory[@cpu.ip + i]) +"\n"
        end
      when /^dump\s+(\d+):(\d+)$/  then
        print "Dump %s to %s\n" %[$1, $2]
        ($1.to_i..$2.to_i).each do |i|
          print i.to_s + ":\t" + @cpu.mu.memory[i].long.to_s + "\n"
        end
      when /^text\s+(\d+):(\d+)$/  then
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