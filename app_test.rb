#!/usr/bin/env ruby
require 'minitest/autorun'
require 'rack/test'
require_relative "app"

set :enviroment, :test

class MyAppTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_root
    get '/'
    assert last_response.ok?
  end
  
  def test_get_all_users_ok
    get '/user'
    assert last_response.ok?
  end
  
  def test_post_user
    post '/user/', params = {"name" = "Alex"}
    assert last_response.ok?
  end
  
  def test_get_all_posts_ok
    get '/post'
    assert last_response.ok?
  end
  
  def test_post_post
    post '/post/', params = {"name" = "titleofpost"}
    assert last_response.ok?
  end
  
  def test_get_all_categories_ok
    get '/categories/all'
    assert last_response.ok?
  end    
end
