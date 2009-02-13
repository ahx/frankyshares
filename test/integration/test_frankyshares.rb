require File.dirname(__FILE__) + '/../test_helper'

class TestFrankyshares < Test::Unit::TestCase
  include Sinatra::Test  
    
  def setup
    @test_file = File.dirname(__FILE__) + '/../data/test.png'
    Frankyshares.public = File.dirname(__FILE__) + '/../data/'
    @app = Frankyshares
  end
  
  def test_should_upload_file    
    get "/"
    assert response.ok?
    # assert response.body.include?('<input name="file" size="30" type="file" />')
    # TODO Finish this test, when this works with Webrat and not using Rails
    # attach_file "file", @test_file
    # click_button "upload"
  end
  
  def test_should_show_download_link
    get "/1234"
    assert response.body.include?('<a href="/files/1234/test.png" title="Download this file now!">Download <i>test.png</i> now</a>')
  end
end