require File.dirname(__FILE__) + '/autoload'
disassembler = Disassembler.new
assembler = Assembler.new
mix = CPU.new
mix.disassembler = disassembler
assembler.disassembler = disassembler
program = '1-fibonacci.mix'
#program ='2-500primes.mix'
file = File.dirname(__FILE__) + '/../examples/' + program


assembler.parse_lines File.open(file, 'r')
assembler.load_cpu(mix)
print mix.ip.to_s + "\n"
until mix.halt do
  mix.clock
end

(3000..3031).each do |i|
  print mix.memory[i].long.to_s << ' '
end
print "\n"