#encoding: utf-8

require File.dirname(__FILE__) + '/../frankyshares'
require 'fileutils'
require 'rack/test'
require 'test/unit'
require 'timecop'

class TestFrankyshares < Test::Unit::TestCase
  include Rack::Test::Methods
  
  TEST_DIR = File.dirname(__FILE__) + '/data'  
  Frankyshares.upload_dir = TEST_DIR
  Frankyshares.time_to_expire = 10
  
  def app
   Frankyshares
  end
  
  def setup
    FileUtils.mkdir_p TEST_DIR
  end
  
  def teardown
    FileUtils.rm_r TEST_DIR
  end
  
  def test_homepage
    get "/" 
    assert last_response.ok?
  end

  def test_upload_file        
    post "/", "file" => Rack::Test::UploadedFile.new(__FILE__)
    assert last_response.redirect?
    follow_redirect!
    assert last_response.ok?
    assert last_request.path =~ /\/\w+/, "path should be something like '/abc123', but was #{last_request.path}"
    assert last_response.body.include?("test_frankyshares.rb"), "body should include filename but did not."
  end
  
  def test_post_empty_form
    post "/", "foo" => "bar"
    assert last_response.ok?
  end
  
  def test_not_found
    get "/whatever"    
    assert last_response.not_found?
  end
  
  def test_expire_file
    # upload file
    post "/", "file" => Rack::Test::UploadedFile.new(__FILE__)
    assert last_response.redirect?
    follow_redirect!
    path = last_request.path
    # fast-forward in time
    Timecop.freeze(Time.now + Frankyshares.time_to_expire +1) do
      # request file info
      get path
      assert last_response.not_found?, "Should be 404, but was #{last_response}"
      assert !File.exist?(Frankyshares.upload_dir + path), "Folder should have been removed."
    end
  end
end
