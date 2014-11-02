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
  
  ## Users
  
  def test_get_all_users_ok
    get '/user'
    assert last_response.ok?
  end
  
  def test_post_user
    post '/user/', params = {"name" => "Alex"}
    assert last_response.ok?
  end
  
  #Not sure about IDs
  def test_get_user_ok
    get '/user/id/Alex'
    assert last_response.ok?
  end 

  def test_put_user
    put '/user/id/Alex', params = {"name" => "Bob"}
    assert last_response.ok?
  end

  def test_delete_user
    delete '/user/id/Bob'
    assert last_response.ok?
  end
  
  ## User Authentication and Activation
  # Have no idea how this works
  
  def test_post_user_auth
    post '/user/auth', params = {"name" => "Alex"}
    assert last_response.ok?
  end
  
  def test_post_user_deauth
    post '/user/deauth'
    assert last_response.ok?
  end
  
  def test_get_user_activate
    get '/user/activate/Alex'
    assert last_response.ok?
  end 

  ## Posts
  
  def test_get_all_posts_ok
    get '/post'
    assert last_response.ok?
  end
  
  def test_post_post
    post '/post/', params = {"name" => "titleofpost"}
    assert last_response.ok?
  end
  
  #Not sure about IDs
  def test_get_post_ok
    get '/post/id/titleofpost'
    assert last_response.ok?
  end

  def test_put_post
    put '/user/id/titleofpost', params = {"name" => "newposttitle"}
    assert last_response.ok?
  end

  def test_delete_post
    delete '/user/id/newposttitle'
    assert last_response.ok?
  end

  ## Categories  
  
  def test_get_all_categories_ok
    get '/categories/all'
    assert last_response.ok?
  end

  #Not sure about IDs
  def test_get_category_ok
    get '/categories/id/electronics'
    assert last_response.ok?
  end       
end
