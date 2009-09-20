require 'test/unit'
require 'rack/test' # http://github.com/brynary/rack-test
require File.dirname(__FILE__) + '/../frankyshares'
require 'fileutils'

class TestFrankyshares < Test::Unit::TestCase
  include Rack::Test::Methods
  TEST_DIR = File.dirname(__FILE__) + '/data'  
  Frankyshares.upload_dir = TEST_DIR
  
  def app
    Frankyshares.new    
  end
  
  def setup
    FileUtils.mkdir_p TEST_DIR
  end
  
  def teardown
    FileUtils.rm_r TEST_DIR
  end  
  
  def test_upload_file        
    post "/", "file" => Rack::Test::UploadedFile.new(__FILE__)
    assert last_response.redirect?
    follow_redirect!    
    assert last_request.path =~ /\/\w+/, "path should be something like '/abc123', but was #{last_request.path}"
    assert last_response.body.include?("test_frankyshares.rb"), "body should include filename but did not."
  end
  
  def test_post_empty_form
    post "/", "foo" => "bar"
    last_response.ok?
  end
end
