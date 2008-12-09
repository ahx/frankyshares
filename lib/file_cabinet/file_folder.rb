require 'fileutils'

class FileCabinet
  class FileFolder
    def initialize(basefolder, originalfile)
      @basefolder = basefolder
      @filename = File.basename(originalfile)
    end
  
    # returns the path to the (original) file
    def file(style = :original)   
      "#{@basefolder}/#{style.to_s}/#{@filename}"
    end
  
    def destroy
      FileUtils.rm_r(@basefolder)
    end   
  end
end