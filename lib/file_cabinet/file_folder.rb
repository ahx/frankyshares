require 'fileutils'

class FileCabinet  
  class FileFolder    
    def initialize(basefolder)
      @basefolder = basefolder
      @filename = find_first_file_in("#{@basefolder}/#{ORIGINAL_FOLDERNAME}")
      raise(FileCabinet::OriginalFileNotFound, "Either there is no '#{ORIGINAL_FOLDERNAME}' folder or it is empty. #{basefolder}") if @filename.nil?
    end
  
    # returns the path to the (original) file
    def file(style = :original)   
      f = "#{@basefolder}/#{style.to_s}/#{@filename}"
      File.file?(f) ? f : nil
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
      return nil unless File.directory?(path)
      Dir.entries(path).each { |e| return e if File.file?("#{path}/#{e}") }
      nil
    end    
  end  
end
