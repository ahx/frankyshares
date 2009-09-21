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
  # Iterates through folders and request meta information, which should delete
  # the folder automatically, if expired
  dir = Frankyshares.upload_dir
  FileList[dir + "/*"].each do |f|
    key = f.sub(dir + "/", "")
    FileUtils.rm_rf(File.join(dir, key)) unless Frankyshares.meta_store[key]
  end
end
