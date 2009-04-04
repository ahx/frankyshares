# Provides an interface to save and find Files in a folder
# 
# Usage
# To create a new FileCabinet point it to an EXISTING Folder
# cabinet = FileCabinet.new("~/app/data/files")
# Add/Move a file to the FileCabinet
# folder = cabinet.add_file("/tmp/uploaded/test.jpg") # Gets saved in a random named folder
# folder = cabinet.find(folder.id)  # Finds a folder
# File.file?(folder.file)       # Gets the file
# folder.destroy                # Delete the folder and the file included

require 'fileutils'

class FileCabinet  
  class CabinetPathNotFound < ArgumentError; end
  class FileDoesNotExist < StandardError; end   
  
  # NOTE This might be a "common exception", so you might want to catch this and show information to the user.
  # FIXME Maybe use throw instead of raise?
  class QuotaExceeded < StandardError; end
  
  # Initialize with path to all folders
  def initialize(path, options = {})
    @options = {
      :quota => nil # unlimited quota
    }.merge options
    raise(CabinetPathNotFound, "Directory does not exist #{path.inspect}!") unless File.directory?(path)
    @files_path = File.expand_path(path)
  end
  
  # Find file folder or return nil
  def find(id)    
    folder = FileFolder.new(folder_path(id)) 
    folder.empty? ? nil : folder
  end
  
  # Returns all folders in this file cabin
  def folders
    Dir.glob(@files_path + '/*').
    map{ |f| find(File.basename(f))}.
    compact
  end
  
  def filesize
    # FIXME You might want to cache this in some sort of form?!
    sum = 0
    folders.each{|f| sum += File.size(f.file) unless f.empty? }
    sum
  end
  
  def quota
    @options[:quota] if quota?
  end
  
  def quota?
    @options[:quota].to_i > 0
  end
  
  # Add a file to the cabinet
  def add_file(new_file, options = {})
    raise(FileDoesNotExist, "Cannot add file, because it does not exist!") unless new_file && File.size?(new_file)
    check_disk_quota!(new_file)
    
    new_filename = options[:filename] || File.basename(new_file)
    new_id = generate_new_id(new_filename) 
    path = folder_path(new_id)
      
    # Make folders..    
    FileUtils.mkdir_p(path)
    # and copy file..
    FileUtils.cp(new_file, File.join(path, new_filename))
    # TODO chmod is too much responsibility for this thing!
    FileUtils.chmod(0644, File.join(path, new_filename))
    
    # return FolderInstance
    FileFolder.new(path)
  end
    
  private
  
  def folder_path(id)
    "#{@files_path}/#{id}"
  end
  
  def generate_new_id(filename)
    "#{Time.now.to_i}#{rand(9)}".to_i.to_s(36)
  end
  def check_disk_quota!(new_file)
    total = filesize + File.size(new_file)
    raise(QuotaExceeded, "Cannot add file, because this file cabinet is full.") if quota && total > quota    
  end
  
  class FileFolder
    def initialize(basefolder)
      @basefolder = basefolder
      @filename = find_first_file_in(@basefolder)        
    end

    # returns the path to the file
    def file
      File.join(@basefolder, @filename) if @filename
    end

    def destroy
      FileUtils.rm_r(@basefolder)
    end

    def id
      File.basename(@basefolder)
    end

    def empty?
      file.nil?
    end

    private

    # find first file in path if exists or return nil
    def find_first_file_in(path)
      if File.directory?(path)
        Dir.entries(path).each { |f| 
          return f if File.file?(File.join(path, f)) 
        }
        nil
      end
    end    
  end  
end
