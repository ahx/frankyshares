require File.dirname(__FILE__) + '/helpers'

class TestFileCabinet < Test::Unit::TestCase
  TEST_DIR = Dir.tmpdir + "/#{self.name}-test-files"

  def delete_test_dir
    FileUtils.rm_r(TEST_DIR)
  end

  context "An existing file" do
    setup do  
      FileUtils.mkdir_p(TEST_DIR + '/xyz')
      FileUtils.touch(TEST_DIR + '/xyz/testfile')  
      @cabinet = FileCabinet.new(TEST_DIR)
      @folder = @cabinet.find("xyz")              
    end

    should "be findable" do
      assert_not_nil folder = @cabinet.find(@folder.id)
      assert File.file?(folder.file)
    end

    should "list all folders" do
      assert @cabinet.folders.map{|f| f.file }.include?(@folder.file)
    end

    context "that has been destroyed" do
      setup do
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
            
    test "an empty folder should not be findable" do
      FileUtils.mkdir_p(TEST_DIR + "/empty")
      assert_nil @cabinet.find("empty")
    end
    
    teardown do
      delete_test_dir
    end
  end
  

  context "When a new file was added" do
    setup do
      FileUtils.mkdir(TEST_DIR)  
      @cabinet = FileCabinet.new(TEST_DIR)
      @file_to_be_added = File.dirname(__FILE__) + '/data/test.png'
      # adding the file!
      @folder = @cabinet.add_file(@file_to_be_added)
    end
  
    test "the add method return the same as finding the file with find" do
        assert_equal(@folder.file, @cabinet.find(@folder.id).file)
    end
    
    test "filesize should be about this big" do
      about = (20_000..30_000)
      assert about.include?(@cabinet.filesize), "filesize is not in expected range. It's #{@cabinet.filesize}"
    end
  
    test "should be findable" do
      assert_not_nil folder = @cabinet.find(@folder.id)
      assert File.file?(folder.file)
    end
      
    test "should be a copy of the original file but not the same file" do
      assert FileUtils.identical?(@file_to_be_added, @folder.file)
      assert_not_equal(@tmp_file, @folder.file)
    end
  
    test "should have retained its original filename" do
      assert_equal("test.png", File.basename(@folder.file))
    end          
    
    context "with a specific filename" do
      setup do
        # adding the file
        @folder = @cabinet.add_file(@file_to_be_added, :filename => "special")
      end
    
      test "should have that specific filename" do
        assert_equal("special", File.basename(@folder.file))
      end
    end  
          
    teardown do
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
      setup do 
        FileUtils.mkdir(TEST_DIR)        
      end

      test "quota exceeded" do
        @cabinet = FileCabinet.new(TEST_DIR, :quota => 1)  # quota in Bytes
        @file_to_be_added = File.dirname(__FILE__) + '/data/test.png'
        assert_raise(FileCabinet::QuotaExceeded) {  
          @cabinet.add_file(@file_to_be_added)
        }
      end
    
      test "when trying to add a non existing file" do
        @cabinet = FileCabinet.new(TEST_DIR)
        assert_raise(FileCabinet::FileDoesNotExist) do
           @cabinet.add_file("nonexistent") 
         end
      end
    
      teardown do
        delete_test_dir
      end      
    end
  end
end
