$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << File.dirname(__FILE__) + '/../generated'
require 'runtime/Runtime'
require 'readline'
runtime = Runtime.new

Readline.completion_append_character=''
Readline.completion_proc = Proc.new do |str|
  Dir[str+'*'].grep( /^#{Regexp.escape(str)}/ )
end

while buf = Readline.readline("> ", true)
 runtime.execute(buf)
end