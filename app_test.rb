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
  
 ## Posts
 def test_post
    post_uuid = SecureRandom.uuid
    user_uuid = SecureRandom.uuid
    category_uuid = SecureRandom.uuid 

    post '/post', body = { 'id' => post_uuid, 'user_id' => user_uuid, 'title' => 'Bike for sale', 'description' => 'New bike', 'category_id' => 'category_uuid', 'cost' => '10' }.to_json
    assert last_response.ok?, 'Error in POST /post response'

    put "/post/id/#{post_uuid}" , body = { 'title' => 'New Bike for sale', 'description' => 'One New bike', 'cost' => '20' }.to_json
    assert last_response.ok?, 'Error in PUT /post/id response'

    get "/post/id/#{post_uuid}"
    assert last_response.ok?, 'Error in GET /post/id response'
    test_post = last_response.body
    test_post = JSON.parse(test_post)
    assert test_post['id'] == post_uuid, 'Error in GET /post/id'
    assert test_post['user_id'] == user_uuid, 'Error in GET /post/id'
    assert test_post['title'] == 'New Bike for sale', 'Error in GET /post/id'
    assert test_post['description'] == 'One New bike', 'Error in GET /post/id'
    assert test_post['category_id'] == category_uuid, 'Error in GET /post/id'
    assert test_post['cost'] == '20', 'Error in GET /post/id'

    get '/post/all'
    assert last_response.ok?, 'Error in GET /post/all response'
    all_posts = last_response.body
    all_posts = JSON.parse(all_posts)
    assert all_posts.include?(test_post), 'Error in GET /post/all does not include newly added post'
    
    delete "/post/id/#{post_uuid}"
    assert last_response.ok?, 'Error in DELETE /post/id response'
    
    get '/post/all'
    all_posts = last_response.body
    all_posts = JSON.parse(all_posts)
    assert !(all_posts.include? test_post), 'Error in DELETE /post/id does not remove post'
end

## Categories
def test_category
    category_uuid = SecureRandom.uuid

    post '/category', body = { 'id' => category_uuid, 'name' => 'Furniture' }.to_json
    assert last_response.ok? , 'Error in POST /category response'

    get "/category/id/#{category_uuid}"
    assert last_response.ok?, 'Error in GET /category/id response'
    test_category = last_response.body
    test_category = JSON.parse(test_category)
    assert test_category['id'] == category_uuid, 'Error in GET /category/id'
    assert test_category['name'] == 'Furniture', 'Error in GET /category/id'
    
    get '/category/all'
    assert last_response.ok? , 'Error in GET /category/all response'
    all_categories = last_response.body
    all_categories = JSON.parse(all_categories)
    assert all_categories.include?(test_category), 'Error in GET /category/all does not include newly added Category'
end
end