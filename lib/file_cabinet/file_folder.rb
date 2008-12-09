require 'fileutils'

class FileCabinet
  class FileFolder
    
    # load an existing folder
    def self.load(path)
      raise FileCabinet::FileNotFound unless File.directory?(path+"/original")
      new(path)
    end
    
    def initialize(path)
      @folder_path = path
      @basename = find_basename
      raise FileCabinet::FileNotFound unless @basename
    end
  
    # returns the path to the (original) file
    def file(style = :original)   
      "#{@folder_path}/#{style.to_s}/#{@basename}"
    end
  
    def destroy
      FileUtils.rm_r(@folder_path)
    end
  
    private 
  
    # find name of first file in original folder if exists or return nil
    def find_basename
      path = "#{@folder_path}/original"
      Dir.entries(path).each do |e| 
        return e if File.file?("#{path}/#{e}"); 
      end
      return nil
    end    
  end
end