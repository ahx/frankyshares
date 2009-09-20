require 'rake'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new(:test) do |t|
  t.libs << File.dirname(__FILE__)
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end
