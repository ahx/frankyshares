require "test/unit"
require 'fileutils'

$LOAD_PATH << File.dirname(__FILE__) + '../lib'
require 'file_cabinet'

class TestFileCabinet < Test::Unit::TestCase
  def setup
    # TODO This is totally unacceptable!
    FileUtils.mkdir_p(File.expand_path(File.dirname(__FILE__) + '/data/tmp/xyz/original'))
    FileUtils.mkdir_p(File.expand_path(File.dirname(__FILE__) + '/data/tmp/empty'))
    @tmp_file = FileUtils.touch(File.expand_path(File.dirname(__FILE__) + '/data/tmp/xyz/original/testfile')).first
    @cabinet_files_folder = File.expand_path(File.dirname(__FILE__) + '/data/tmp')
    @cabinet = FileCabinet.new(@cabinet_files_folder)
  end
  
  def teardown
    FileUtils.rm_r Dir.glob(File.expand_path(File.dirname(__FILE__) + '/data/tmp/*'))    
  end
  
  def test_new_should_complain_if_created_without_a_valid_folder
    assert_raise(FileCabinet::InvalidCabinetPath) do
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
  end
  
  def test_what_to_do_when_dir_is_empty?
    assert_raise(FileCabinet::OriginalFileNotFound) do
      assert @cabinet.find("empty")
    end
  end
  
  def test_should_add_file_to_cabinet    
    assert folder = @cabinet.add_file(@tmp_file)
    
    # There should be a folder :cabinet/:id
    assert_not_nil(folder.id)
    assert File.directory?(@cabinet_files_folder + "/#{folder.id}"), "Folder not in place"
    
    # There should be a folder :cabinet/:id/original
    orig = @cabinet_files_folder + "/#{folder.id}/original"
    assert File.directory?(orig), "Original folder not in place"
    # ... with the file in it, copied from the @tmp_file
    assert FileUtils.identical?(File.expand_path(@tmp_file), orig + "/" + File.basename(folder.file))
    
    # file should be a COPY, but NOT the same file
    assert_not_equal(@tmp_file, folder.file)  
  end
  
  def test_should_add_file_with_special_filename
    assert File.exist?(@tmp_file)
    myname = "custom filename"
    assert folder = @cabinet.add_file(@tmp_file, :filename => myname)    
    assert_equal(myname, File.basename(folder.file))
    # assert_equal(myname, File.basename(@cabinet.find(folder.id).file))
  end
  
  def test_should_not_add_file_to_cabinet
    @tmp_file = File.dirname(__FILE__) + '/doesnotexist'    
    assert(!File.exist?(@tmp_file), "File should not exist")
    
    assert_raise(FileCabinet::CannotAddFile) { @cabinet.add_file(File.expand_path(@tmp_file)) }
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
