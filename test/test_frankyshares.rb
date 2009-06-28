require File.dirname(__FILE__) + '/helpers'

class TestFrankyshares < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    Frankyshares.new
  end
  
  def setup
    @test_file = File.dirname(__FILE__) + '/data/test.png'
    Frankyshares.public = File.dirname(__FILE__) + '/data/'
  end  
  
  def test_should_upload_file    
    get "/"
    assert last_response.ok?
    # assert response.body.include?('<input name="file" size="30" type="file" />')
    # TODO Write this test, maybe using webrat?
    # attach_file "file", @test_file
    # click_button "upload"
  end
  
  def test_should_show_download_link
    get "/1234"
    assert last_response.body.include?('<a href="/files/1234/test.png"')
  end
end