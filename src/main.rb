$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << File.dirname(__FILE__) + '/../generated'
require 'runtime/Runtime'
require 'readline'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
    end
  opts.on("-e", "--execute PROGRAM", "Executes program non interactively") do |v|
    options[:execute] = v
  end
end.parse!

runtime = Runtime.new(options)

runtime.run