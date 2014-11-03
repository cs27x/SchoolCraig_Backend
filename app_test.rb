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
  
  def setup
      @@user_uuid = SecureRandom.uuid
      @@post_uuid = SecureRandom.uuid
  end

  ## Users
  
  def test_get_all_users_ok
    get '/user'
    assert last_response.ok? , "Error in getting all users"
  end
  
  def test_post_user
    post '/user', body = { "id" => @@user_uuid, "fname" => "Alex" , "lname" => "Alex", "email" => "test@vanderbilt.edu", "password" => "pwd" }
    assert last_response.ok? , "Error in creating a users"
  end
  
  def test_put_user
    put '/user/id', params = { "userid" => @@user_uuid }
    assert last_response.ok? , "Error in put user"
  end

  ## User Authentication and Activation
  
  def test_post_user_auth
    post '/user/auth', body = { "email" => "test@vanderbilt.edu", "password" => "pwd" }
    assert last_response.ok?, "Error in user auth"
  end
  
  def test_get_user_activate
   get 'user/activate/:id', id: @@user_uuid
   assert last_response.ok?, "Error in user activate"
  end 

  def test_get_user_ok
    get 'user/id', id: @@user_uuid
    assert last_response.ok? , "Error in getting a user"
  end 
  
  ## Posts
  
  def test_get_all_posts_ok
    get '/post'
    assert last_response.ok?, "Error in getting all posts"
  end
  
  def test_post_post
    post '/post/', body = { "id" => @@user_uuid, "description" => "New post" }
    assert last_response.ok?, "Error in creating a post"
  end
  
  def test_get_post_ok
    get '/post/id', id: @@post_uuid
    assert last_response.ok?, "Error in getting a post"
  end

  def test_put_post
    put '/post/id/postid', params = { "postid" => @@post_uuid }
    assert last_response.ok?, "Error in put post"
  end

  def test_delete_post
    delete '/post/id/postid', params = { "postid" => @@post_uuid }
    assert last_response.ok?, "Error in deleting a post"
  end


  ## Categories  
  
  def test_get_all_categories_ok
    get '/categories/all'
    assert last_response.ok?, "Error in getting all categories"
  end

  #Not sure about category_id
  def test_get_category_ok
    get '/categories/id', category_id: "electronics"
    assert last_response.ok?, "Error in getting a catogory"
  end       

  def test_post_user_deauth
      post '/user/deauth'
      assert last_response.ok?, "Error in user deauth"
  end

  def test_delete_user
      delete 'user/id', id:  @@user_uuid 
      assert last_response.ok?, "Error in deleting a user"
  end
  
end
