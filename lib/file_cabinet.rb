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
  class OriginalFileNotFound < StandardError; end
  
  # Initialize with path to all folders
  def initialize(path)
    raise(CabinetPathNotFound, "Directory does not exist #{path.inspect}!") unless File.directory?(path)
    @files_path = File.expand_path(path)
  end
  
  # Find file folder or return nil
  def find(id)    
    f = folder_path(id)    
    FileFolder.new(f) if File.directory?(f) 
  end
  
  # Returns all folders in this file cabin
  def folders
    Dir.glob(@files_path + '/*').
    map{ |f| find(File.basename(f))}.
    compact
  end
  
  # Add a file to the cabinet
  def add_file(file, options = {})      
    raise(FileDoesNotExist, "Cannot add file, because it already exists!") if !File.exist?(file)
    new_filename = options[:filename] || File.basename(file)
    new_id = generate_new_id(new_filename) 
    path = folder_path(new_id)
      
    # Make folders..    
    FileUtils.mkdir_p(path)
    # and copy file..
    FileUtils.cp(file,    File.join(path, new_filename))
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
  
  class FileFolder
    def initialize(basefolder)
      @basefolder = basefolder
      @filename = find_first_file_in(@basefolder) ||
        raise(FileCabinet::OriginalFileNotFound, "Cannot find original file in #{basefolder}!")
    end

    # returns the path to the file
    def file()
      f = File.join(@basefolder, @filename)
      f if File.file?(f)
    end

    def destroy
      FileUtils.rm_r(@basefolder)
    end

    def id
      File.basename(@basefolder)
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
