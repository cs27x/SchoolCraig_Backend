#!/usr/bin/env ruby
# Encoding: utf-8

require 'sinatra'
require 'json'
require 'sinatra/activerecord'

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

class Post < ActiveRecord::Base
  self.table_name = 'posts'
  self.primary_key = 'id'
end

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
