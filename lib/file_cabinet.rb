# Provides an interface to manage Files in a folder
# TODO save different styles of a file (compare with Paperclip)
# 
# Usage
# To create a new FileCabinet point it to an EXISTING Folder
# cabinet = FileCabinet.new("~/app/data/files")
# Use .add_file To save a file in the FileCabinet
# cabinet.add_file("/tmp/yxz/test.jpg")
# The file gets saved into a randomly named folder
# Use .find to find a folder 
# folder = cabinet.find("xyz")
# use .file to get the actual file, saved in the folder
# File.file?(folder.file) # should return true
# use folder.destroy to delte a folder/file
# folder.destroy

require 'fileutils'
require 'file_cabinet/file_folder'

class FileCabinet  
  class FilesPathNotValid < ArgumentError; end
    
  # Initialize with path to all folders
  def initialize(path, options = {}) 
    raise FilesPathNotValid unless File.directory?(path)
    @original_foldername = options[:orginal_foldername] || 'original'
    # TODO add styles and image processing (see Paperclip)...
    # @styles = options[:styles] || {}    
    @files_path = path
  end
  
  # Find file folder or return nil
  def find(id)
    # Check requirements for a FileFolder...
    basefolder = "#{@files_path}/#{id}"
    originalfolder = "#{basefolder}/#{@original_foldername}"
    return nil unless originalfile = find_first_file_in(originalfolder)
    FileFolder.new(basefolder, originalfile)
  end
  
  # Add a file to the cabinet
  def add_file(file)        
    newid = "#{Time.now.to_i}#{rand(9)}".to_i.to_s(36).sub("-","s") + "-" + File.extname(file).downcase    
    
    FileUtils.mkdir_p(orig_folder = (path = "#{@files_path}/#{newid}") + "/#{@original_foldername}")
    FileUtils.cp(file, orig_folder)
    FileFolder.new(path, "#{orig_folder}/#{File.basename(file)}")
  end
  
  private
  
  # find first file in path if exists or return nil
  def find_first_file_in(path)
    return nil unless File.directory?(path)
    Dir.entries(path).each do |e| 
      entry_path = "#{path}/#{e}"
      return entry_path if File.file?(entry_path); 
    end
    nil
  end
end