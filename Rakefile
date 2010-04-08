require 'rake'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new(:test) do |t|
  t.libs << File.dirname(__FILE__)
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

require File.dirname(__FILE__) + "/frankyshares"
require 'fileutils'
desc "Remove expired files"
task :cron do
  FileList[Frankyshares.upload_dir + "/*"].each do |dir|
    FileUtils.rm_rf(dir) if Frankyshares.expired?(dir)
  end
end
