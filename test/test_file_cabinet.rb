require "test/unit"
require 'fileutils'

$LOAD_PATH << File.dirname(__FILE__) + '../lib'
require 'file_cabinet'

class TestFileCabinet < Test::Unit::TestCase
  def setup
     # Setup Test-files dir
    FileUtils.mkdir_p(File.expand_path(File.dirname(__FILE__) + '/data/tmp/xyz/original'))
    FileUtils.mkdir_p(File.expand_path(File.dirname(__FILE__) + '/data/tmp/empty'))
    FileUtils.touch(File.expand_path(File.dirname(__FILE__) + '/data/tmp/xyz/original/testfile'))
    @cabinet = FileCabinet.new(File.expand_path(File.dirname(__FILE__) + '/data/tmp'))
  end
  
  def teardown
    FileUtils.rm_r Dir.glob(File.expand_path(File.dirname(__FILE__) + '/data/tmp/*'))    
  end
  
  def test_new_should_complain_if_created_without_a_valid_folder
    assert_raise(FileCabinet::FilesPathNotValid) do
      FileCabinet.new(File.expand_path(File.dirname(__FILE__) + '/wrongfolder'))
    end
  end
  
  def test_should_find_file
    assert f = @cabinet.find("xyz"), "File not found!"
    assert File.file?(f.file), "File #{f.file.inspect} is not a file!"
    assert_equal(File.basename(f.file), "testfile")
  end
  
  def test_should_not_find_file
    assert_raise(FileCabinet::FileNotFound) { f = @cabinet.find("filenotfound"); }
    assert_raise(FileCabinet::FileNotFound) { f = @cabinet.find("empty"); }    
  end
  
  def test_should_save_file_in_cabinet_and_destroy
    # add
    tmp_file = File.dirname(__FILE__) + '/data/doc'
    f = @cabinet.add_file(File.expand_path(tmp_file))
    assert File.file?(file = f.file), "File #{f.file.inspect} is not a file!"
    assert FileUtils.identical?(tmp_file, file)
    assert_not_equal(tmp_file, file)  # file should be a COPY, not the same file
    # destroy
    f.destroy
    assert !File.exist?(file), "File #{file} should not be a file!"
  end
end
