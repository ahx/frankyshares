require 'test_helper'

require 'file_cabinet'
require 'fileutils'
require 'tmpdir'

class TestFileCabinet < Test::Unit::TestCase
  # Directory for generated test-files. This directory will be destroyed afterwards.
  TEST_DIR = Dir.tmpdir + "/#{self.name}-test-files"

  def delete_test_dir
    FileUtils.rm_r(TEST_DIR)
  end

context "An existing file" do
  before do  
    FileUtils.mkdir_p(TEST_DIR + '/xyz')
    FileUtils.touch(TEST_DIR + '/xyz/testfile')  
    @cabinet = FileCabinet.new(TEST_DIR)    
    @folder = @cabinet.find("xyz")
  end

  should "be findable" do
    assert_not_nil folder = @cabinet.find(@folder.id)
    assert File.file?(folder.file)
  end


  context "that has been destroyed" do
    before do
      @filepath = @folder.file  # saving file path
      @folder.destroy
    end

    should "not be findable" do
      assert_nil @cabinet.find(@folder.id)
    end
  
    should "be removed from the filesystem" do        
      assert !File.exist?(@filepath)
    end
  end
  
  after do
    delete_test_dir
  end
end


context "When a new file is added" do
  before do
    FileUtils.mkdir(TEST_DIR)  
    @cabinet = FileCabinet.new(TEST_DIR)
    @file_to_be_added = FileUtils.touch(TEST_DIR + '/my_uploaded_file').first      
    # adding the file!
    @folder = @cabinet.add_file(@file_to_be_added)
  end
  
  test "the add method return the same as finding the file with find" do
      assert_equal(@folder.file, @cabinet.find(@folder.id).file)
  end
  
  it "should be findable" do
    assert_not_nil folder = @cabinet.find(@folder.id)
    assert File.file?(folder.file)
  end
      
  it "should be a copy of the original file but not the same file" do
    assert FileUtils.identical?(@file_to_be_added, @folder.file)
    assert_not_equal(@tmp_file, @folder.file)
  end
  
  it "should have retained its original filename" do
    assert_equal("my_uploaded_file", File.basename(@folder.file))
  end
      
    
  context "with a specific filename" do
    before do
      # adding the file
      @folder = @cabinet.add_file(@file_to_be_added, :filename => "special")
    end
    
    it "should have that specific filename" do
      assert_equal("special", File.basename(@folder.file))
    end
  end  
  
  after do
    delete_test_dir
  end        
end


context "It should throw exceptions" do
  
  test "when a file cabinet is initialized without an existing folder" do
    assert_raise(FileCabinet::CabinetPathNotFound) do
      FileCabinet.new("nonexistent folder")
    end
  end  
  
  
  context "with an existing file cabinet" do
    before do
      FileUtils.mkdir_p(TEST_DIR + "/empty")  
      @cabinet = FileCabinet.new(TEST_DIR)
    end
    
    test "when trying to add a non existing file" do
      assert_raise(FileCabinet::FileDoesNotExist) do
         @cabinet.add_file("nonexistent") 
       end
    end
    
    test "when the original file cannot be found inside a folder" do
      assert_raise(FileCabinet::OriginalFileNotFound) do
        assert @cabinet.find("empty")
      end
    end    
    
    after do
      delete_test_dir
    end      
  end
end

end
