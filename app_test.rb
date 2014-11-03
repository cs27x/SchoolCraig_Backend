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

  ## Users
  
  def test_get_all_users_ok
    get '/user'
    assert last_response.ok? , "Error in getting all users"
  end
  
  def test_post_user
    post '/user', body = {"id" => "1", "fname" => "Alex"}
    assert last_response.ok? , "Error in posting a users"
  end
  
  #Not sure about IDs
  def test_get_user_ok
    get 'user/id',id: "1"
    assert last_response.ok? , "Error in getting a user"
  end 

  def test_put_user
    put '/user/id', params = {"id" => "1", "name" => "Bob"}
    assert last_response.ok? , "Error in put user"
  end

  def test_delete_user
    delete 'user/id',id: "1" 
    assert last_response.ok?, "Error in deleting a user"
  end
  
  ## User Authentication and Activation
  # Have no idea how this works
  
  def test_post_user_auth
    post '/user/auth', params = {"name" => "Alex"}
    assert last_response.ok?, "Error in user auth"
  end
  
  def test_post_user_deauth
    post '/user/deauth'
    assert last_response.ok?, "Error in user deauth"
  end
  
  #def test_get_user_activate
   #get 'user/activate/id', id: "1"
    #assert last_response.ok?, "Error in user activate"
  #end 

  ## Posts
  
  def test_get_all_posts_ok
    get '/post'
    assert last_response.ok?, "Error in getting all posts"
  end
  
  def test_post_post
    post '/post/', params = {"name" => "titleofpost"} , body ={"id" => "1"}
    assert last_response.ok?, "Error in creating a post"
  end
  
  #Not sure about IDs
  def test_get_post_ok
    get '/post/id', id: "1"
    assert last_response.ok?, "Error in getting a post"
  end

  def test_put_post
    put '/user/id/titleofpost', params = {"name" => "newposttitle"}
    assert last_response.ok?, "Error in put post"
  end

  def test_delete_post
    delete '/user/id/newposttitle'
    assert last_response.ok?, "Error in deleting a post"
  end

  ## Categories  
  
  def test_get_all_categories_ok
    get '/categories/all'
    assert last_response.ok?, "Error in getting all categories"
  end

  #Not sure about IDs
  def test_get_category_ok
    get '/categories/id/electronics'
    assert last_response.ok?, "Error in getting a catogory"
  end       
end
