# Provides an interface to manage Files in an ActiveRecord-like way
# By now the original file must be remained saved in :id/original/:basename ,
# where :id and :basename can be anything
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
    # TODO make nice, move to proper factory method...
    newid = "deleteme#{rand}" # test..
    # file_extension = self.file.original_filename[/\w{1,8}$/].downcase
    # self.permalink = "#{Time.now.to_i}#{rand(9)}".to_i.to_s(36).sub("-","s") +"-" + file_extension    
    
    FileUtils.mkdir(path = "#{@files_path}/#{newid}")
    FileUtils.mkdir("#{path}/#{@original_foldername}")
    FileUtils.cp(file, "#{path}/#{@original_foldername}")
    FileFolder.new(path, "#{path}/#{@original_foldername}/#{File.basename(file)}")
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