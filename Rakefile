require 'rake'
require 'frankyshares'

desc "Delete expired files"
task :cron do
  puts Time.now
  root = Frankyshares.public + "/files"
  delete_old_files_in(root)
end


def delete_old_files_in(root)
  puts "Clean up old files in #{root.inspect}"
  deleted = FileCabinet.new(root).folders.
  each do |folder|
    deadline = File.mtime(folder.file).to_i + Frankyshares.time_to_expire
    if deadline - Time.now.to_i <= 0
      puts "  delete #{folder.id} #{folder.destroy}"
    else 
      false
    end
  end
  puts "done. #{deleted.length} folders deleted."
end
