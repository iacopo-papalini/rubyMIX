$:.unshift (File.dirname(__FILE__))
$:.unshift (File.dirname(__FILE__) + '/../generated/')

require 'mix_core'
require 'word'
require 'assembler'
require 'register'
require 'instructions'

assembler = InstructionParser.new
mix = MixCore.new
program = File.dirname(__FILE__) + '/../examples/1-fibonacci.mix'

i = 0
File.open(program, 'r') do |file_handle|
     file_handle.each_line do |line|
       if line[0] == '#'
         next
       end
       command = assembler.as_word(line)
       mix.change_memory_word(i, command)
       i += 1
     end
end


mix.ip = 0

until mix.halt do
  mix.clock
  break if mix.overflow
end

(3000..3030).each do |i|
  print mix.memory[i].long.to_s << ' '
end
print "\n"