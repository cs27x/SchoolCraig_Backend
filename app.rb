#!/usr/bin/env ruby
# Encoding: utf-8

require 'sinatra'
require 'json'
require 'sinatra/activerecord'
require 'securerandom'

RACK_ENV = (ENV["RACK_ENV"] ||= "development").to_sym
set :environment, RACK_ENV

configure :production do
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
end

configure :development do
  db = URI.parse('postgres://postgres:root@localhost/postgres')

  ActiveRecord::Base.establish_connection(
    adapter:  db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    host:     db.host,
    username: db.user,
    password: db.password,
    database: db.path[1..-1],
    encoding: 'utf8'
  )
end

########## Post Class #############
# Used to model posts with ActiveRecord and
# communicate with the Postgres DB
class Post < ActiveRecord::Base
  self.table_name = 'posts'
  self.primary_key = 'id'
end

########## User Class #############
# Used to model users with ActiveRecord and
# communicate with the Postgres DB
class User < ActiveRecord::Base
  self.table_name = 'users'
  self.primary_key = 'id'
end

get '/post/?' do
  content_type :json
  Post.all.to_json
end

get '/post/id/:id' do |id|
  content_type :json
  begin
    Post.find(id).to_json
  rescue ActiveRecord::RecordNotFound
    {}.to_json
  end
end

get '/user/?' do
  content_type :json
  User.all.to_json
end

get '/user/id/:id' do |id|
  content_type :json
  begin
    User.find(id).to_json
  rescue ActiveRecord::RecordNotFound
    {}.to_json
  end
end

post '/post/new/?' do
  content_type :json
  # parses body of post request
  body = request.body.read
  body = JSON.parse(body)
  user = body['user']
  description = body['description']

  if !(description.nil? || user.nil?)
    # logic for email verification goes here
    uuid = SecureRandom.uuid
    Post.create(id: uuid, user: user, description: description)
    { status: 'success' }.to_json
  else
    { status: 'failure' }.to_json
  end
end

post '/user/new/?' do
  content_type :json
  # parses body of post request
  body = request.body.read
  body = JSON.parse(body)
  fname = body['fname']
  lname = body['lname']
  email = body['email']

  if !(fname.nil? || lname.nil? || email.nil?)
    # logic for email verification goes here
    uuid = SecureRandom.uuid
    User.create(id: uuid, fname: fname, lname: lname, email: email)
    { status: 'success' }.to_json
  else
    { status: 'failure' }.to_json
  end
end
