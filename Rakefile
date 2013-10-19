require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)  do    |t|
  t.rspec_opts = '-P src/'
  t.rcov = true
  t.rcov_opts = ['--exclude', 'specs']
end

task :default => :spec