#!/usr/bin/env ruby
gem 'minitest'
require 'minitest/autorun'
require 'rack/test'
require_relative "app"

set :enviroment, :test

class MyAppTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
  def setup
    # use later, perhaps
  end

  ## Users
  def test_user
    user_uuid = SecureRandom.uuid
    
    post '/user', body = { 'id' => user_uuid, 'fname' => 'Alex' , 'lname' => 'Smith', 'email' => 'test@vanderbilt.edu', 'password' => 'pwd' }.to_json
    assert last_response.ok? , 'Error in POST /user response'

    post '/user/auth', body = { 'email' => 'test@vanderbilt.edu', 'password' => 'pwd' }.to_json
    assert last_response.ok? , 'Error in POST /user/auth response'
    
    put "/user/id/#{user_uuid}", body = {'fname' => 'Alexander' , 'lname' => 'Smithy'}.to_json
    assert last_response.ok? , 'Error in PUT /user/id response'

    get "/user/id/#{user_uuid}"
    assert last_response.ok? , 'Error in GET /user/id response'
    test_user = response.body.read
    test_user = JSON.parse(test_user)
    assert test_user['id'] == user_uuid, 'Error in GET /user/id'
    assert test_user['fname'] == 'Alexander', 'Error in GET /user/id'
    assert test_user['lname'] == 'Smithy', 'Error in GET /user/id'
    
    get '/user/all'
    assert last_response.ok? , 'Error in GET /user/all response'
    all_users = response.body.read
    all_users = JSON.parse(all_users)
    assert all_users.include? test_user, 'Error in GET /user/all does not include newly added user'
    
    delete "/user/id/#{user_uuid}"
    assert last_response.ok? , 'Error in DELETE /user/id response'
    get '/user/all'
    all_users = response.body.read
    all_users = JSON.parse(all_users)
    assert !(all_users.include? test_user), 'Error in DELETE /user/id does not remove user'
    
    post '/user/deauth'
    assert last_response.ok? , 'Error in POST /user/deauth response'
    
  end
end
