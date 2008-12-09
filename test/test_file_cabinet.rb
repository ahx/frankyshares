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
    assert @cabinet.find("filenotfound").nil?
    assert @cabinet.find("empty").nil?
  end
  
  def test_should_add_file_to_cabinet
    tmp_file = File.dirname(__FILE__) + '/data/doc'    

    file = @cabinet.add_file(File.expand_path(tmp_file)).file
    assert File.file?(file), "File #{file.inspect} is not a file!"
    assert FileUtils.identical?(tmp_file, file)
    assert_not_equal(tmp_file, file)  # file should be a COPY, not the same file
  end
  
  def test_should_destroy_a_file    
    assert f = @cabinet.find("xyz")
    file = f.file
    assert File.exist?(file)
    
    f.destroy
    assert !File.exist?(file), "File #{file} should not be a file!"
    assert @cabinet.find("xyz").nil?
  end
end
