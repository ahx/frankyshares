# Provides an interface to manage Files in a folder
# TODO save different styles of a file (compare with Paperclip)
# 
# Usage
# To create a new FileCabinet point it to an EXISTING Folder
# cabinet = FileCabinet.new("~/app/data/files")
# Use FileCabinet#add_file To save a file in the FileCabinet
# cabinet.add_file("/tmp/yxz/test.jpg")
# The file gets saved into a randomly named folder
# Use FileCabinet#find to find a folder (returns FileFolder, but that might change)
# folder = cabinet.find("xyz")
# use FileFolder#file to get the actual file, saved in the folder
# File.file?(folder.file) # should return true
# use folder.destroy to delete a folder/file
# folder.destroy

# TODO add styles and image processing (see Paperclip)...

require 'fileutils'
require 'file_cabinet/file_folder'

class FileCabinet  
  
  class CabinetPathNotFound < ArgumentError; end
  class FileDoesNotExist < StandardError; end 
  class OriginalFileNotFound < StandardError; end  
  
  ORIGINAL_FOLDERNAME = 'original'
  
  # Initialize with path to all folders
  def initialize(path)
    raise(CabinetPathNotFound, "Directory does not exist #{path.inspect}!") unless File.directory?(path)
    @files_path = File.expand_path(path)
  end
  
  # Find file folder or return nil
  def find(id)
    path = folder_path(id)
    File.directory?(path) ? FileFolder.new(path) : nil    
  end
  
  # Add a file to the cabinet
  def add_file(file, options = {})      
    raise(FileDoesNotExist, "Cannot add file, because it already exists!") unless File.exist?(file)
    new_filename = options[:filename] || File.basename(file)
    new_id = generate_new_id(new_filename) 
    path = folder_path(new_id)
    original_folder = "#{path}/#{ORIGINAL_FOLDERNAME}"
      
    # Make folders..    
    FileUtils.mkdir_p(original_folder)
    # and copy file..
    FileUtils.cp(file,    "#{original_folder}/#{new_filename}")
    # TODO chmod is too much responsibility for this thing!
    FileUtils.chmod(0644, "#{original_folder}/#{new_filename}")
    
    # return FolderInstance
    FileFolder.new(path)
  end
  
  
  private
  
  def folder_path(id)
    "#{@files_path}/#{id}"
  end
  
  def generate_new_id(filename)
    extension = File.basename(filename)[/\w{1,8}$/].downcase    
    "#{Time.now.to_i}#{rand(9)}".to_i.to_s(36) + "-" + extension
  end
end
