# Provides an interface to manage Files in an ActiveRecord-like way
# By now the original file must be remained saved in :id/original/:basename ,
# where :id and :basename can be anything
require 'fileutils'
require 'file_cabinet/file_folder'

class FileCabinet  
  class FileNotFound < StandardError; end
  class FilesPathNotValid < StandardError; end
  
  def initialize(path)
    raise FilesPathNotValid unless File.directory?(path)
    @files_path = path
  end
  
  def find(id)
    FileFolder.load("#{@files_path}/#{id}")
  end
  
  def add_file(file)    
    # TODO make nice, move to proper factory method...
    newid = "deleteme#{rand}" # test..
    #  file_extension = self.file.original_filename[/\w{1,8}$/].downcase
    # self.permalink = "#{Time.now.to_i}#{rand(9)}".to_i.to_s(36).sub("-","s") +"-" + file_extension    
    
    FileUtils.mkdir(path = "#{@files_path}/#{newid}")
    FileUtils.mkdir("#{path}/original")
    FileUtils.cp(file, "#{path}/original")
    FileFolder.load(path)
  end
end