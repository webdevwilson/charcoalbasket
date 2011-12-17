$:.unshift File.join(File.dirname(__FILE__),'..')

require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'webrat'
require 'test/unit'
require 'main'

Webrat.configure do |config|
  config.mode = :rack
end

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
  
  def app
    Sinatra::Application.new
  end

  def test_template_links
    
    visit '/page/home.html'
    
    click_link 'How To Use'
    assert_contain 'Using your Charcoal Basket'
    
    click_link 'Popular Smokers'
    assert_contain 'Charcoal Baskets for Offset Smokers'
    
    click_link 'Drum Smokers'
    assert_contain 'Charcoal Baskets for Drum Smokers'
    
    click_link 'Custom'
    assert_contain 'Order a Custom Charcoal Basket'
    
    click_link 'FAQ\'s'
    assert_contain 'Frequently Asked Questions'
    
    click_link 'Contact Us'
    assert_contain 'Give Us Your Feedback'
    
    click_link 'Buy Now'
    assert_contain '12" x 12" x 6" Charcoal Basket'
    
    click_link 'Privacy Policy'
    assert_contain 'General Statement of Principles'
    
    click_link 'Terms & Conditions'
    assert_contain 'Copyright'
    
  end

  def test_nonsense_urls_redirect_to_homepage
    visit '/this-page-does-not-exist'
    assert_equal 404, response.status
    assert_contain 'Page Not Found'
  end
  
  def test_non_existing_pages_show_page_not_found
    visit '/page/blah.html'
    assert_equal 404, response.status
    assert_contain 'Page Not Found'
  end
  
  def test_legacy_redirects
  
    visit '/page/minion-method'
    assert_equal 301, response.status
    check_redirect '/page/minion-method.html'
    
    visit '/page/grills'
    assert_equal 404, response.status
    assert_contain 'Page Not Found'
    
    visit '/page/purchase'
    assert_equal 301, response.status
    check_redirect '/purchase/standard/size.html'
    
    visit '/page/privacy'
    assert_equal 301, response.status
    check_redirect '/page/privacy.html'
    
    visit '/page/terms-conditions'
    assert_equal 301, response.status
    check_redirect '/page/terms-conditions.html'
    
    visit '/page/feedback'
    assert_equal 301, response.status
    check_redirect '/page/feedback.html'

    visit '/forms/send'
    assert_equal 404, response.status
    assert_contain 'Page Not Found'
    
  end
  
  def check_redirect(url)
    redirect = response.headers['Location']
    assert /#{url}$/.match( redirect ), "should redirect to '#{url}', got '#{redirect}'"
  end
  
end
