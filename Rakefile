require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '-P src/ -r ./spec_helper.rb'

end

task :default => :spec