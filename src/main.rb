require "readline"
require File.dirname(__FILE__) + '/autoload'
disassembler = Disassembler.new
assembler = Assembler.new
cpu = CPU.new
cpu.disassembler = disassembler
assembler.disassembler = disassembler
assembler.logger =cpu.logger

cpu.bind_io_device(18, STDOUT)

Readline.completion_append_character=''
Readline.completion_proc = Proc.new do |str|
  Dir[str+'*'].grep( /^#{Regexp.escape(str)}/ )
end

last_command = ''
while buf = Readline.readline("> ", true)
  if buf == ''
    buf = last_command
    cpu.clock
  end
  case buf
    when /^load\s+(.+)$/ then
      assembler.parse_lines File.open($1.strip, 'r')
      print "Loaded %s\n" %$1
      assembler.load_cpu(cpu)
    when /^(r[ax])$/ then
      print cpu.send($1).long.to_s + "\n"
    when /^ri([1-6])$/ then
      print cpu.ri[$1.to_i - 1].long.to_s + "\n"
    when /^next\s+(\d+)$/ then
      $1.to_i.times do |i|
        print (cpu.ip + i).to_s + "\t" + disassembler.disassemble(cpu.mu.memory[cpu.ip + i]) +"\n"
      end
    when /^dump\s+(\d+):(\d+)$/  then
      print "Dump %s to %s\n" %[$1, $2]
      ($1.to_i..$2.to_i).each do |i|
        print i.to_s + ":\t" + cpu.mu.memory[i].long.to_s + "\n"
      end
    when /^text\s+(\d+):(\d+)$/  then
      print "Dump as text %s to %s\n" %[$1, $2]
      ($1.to_i..$2.to_i).each do |i|
        print i.to_s + ":\t" + cpu.mu.memory[i].string + "\n"
      end
    when /^run(\s(\d+))?$/ then
      while ($2 == nil or cpu.ip != $2.to_i) and !cpu.halt
        cpu.clock
      end
    when /^debug off$/ then
      cpu.logger.level = Logger::INFO
    when /^debug on/ then
      cpu.logger.level = Logger::DEBUG
    else
      print "Unknown command <%s>\n" % buf
  end
  last_command = buf
end