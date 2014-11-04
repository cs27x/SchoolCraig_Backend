#!/usr/bin/env ruby
# Encoding: utf-8

require 'sinatra'
require 'json'
require 'sinatra/activerecord'
require 'securerandom'
require 'pg'
require 'digest'
require 'mail'

RACK_ENV = (ENV["RACK_ENV"] ||= "development").to_sym
set :environment, RACK_ENV

enable :sessions

Mail.defaults do
  delivery_method :smtp, {
    :address => 'smtp.sendgrid.net',
    :port => '587',
    :domain => 'heroku.com',
    :user_name => ENV['SENDGRID_USERNAME'],
    :password => ENV['SENDGRID_PASSWORD'],
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end

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

########## Category Class #############
# Used to model categories with ActiveRecord and
# communicate with the Postgres DB
class Category < ActiveRecord::Base
  self.table_name = 'categories'
  self.primary_key = 'id'
end

def isUUID?(id)
  !!/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.match(id)
end

########## /category #############
get '/category/all' do
  content_type :json
  Category.all.to_json
end

get '/category/id/:id' do |id|
  unless isUUID?(id) then halt(401) end
  content_type :json
  begin
    Category.find(id).to_json
  rescue ActiveRecord::RecordNotFound
    {}.to_json
  end
end

########## /post #############
post '/post' do
  content_type :json
  # parses body of post request
  body = request.body.read
  body = JSON.parse(body)
  id = body['id']
  user_id = body['user_id']
  description = body['description']
  category = body['category']

  
  [id, user_id, category].each do |x| 
    unless isUUID?(x) then halt(401) end
  end

  if [description, user_id, category].all?
    # logic for email verification goes here
    id ||= SecureRandom.uuid
    Post.create(id: id, user_id: user_id, description: description, category_id: category)
  else
    halt 401
  end
end

get '/post/all' do
  if !session[:user_id] then halt(401) end
  content_type :json
  Post.all.to_json
end

delete '/post/id/:id' do |id|
  unless isUUID?(id) then halt(401) end
  if Post.delete(id).zero? then halt(401) end
end

put '/post/id/:id' do |id|
  unless isUUID?(id) then halt(401) end
  content_type :json
  # parses body of post request
  body = request.body.read
  body = JSON.parse(body)
  description = body['description']
  category_id = body['category_id']
  
  if [description, category].all?
    # logic for email verification goes here
    Post.update(id, description: description, category_id: category_id)
    { status: 'success' }.to_json
  else
    halt 401
  end 
end

get '/post/id/:id' do |id|
  unless isUUID?(id) then halt(401) end
  content_type :json
  begin
    Post.find(id).to_json
  rescue ActiveRecord::RecordNotFound
    {}.to_json
  end
end

########## /user #############
post '/user' do
  content_type :json
  # parses body of post request
  body = request.body.read
  body = JSON.parse(body)
  uuid = body['id']
  fname = body['fname']
  lname = body['lname']
  email = body['email']
  password = body['password']

  if [fname, lname, email, password].all?

    salt = SecureRandom.hex
    password = Digest::SHA256.hexdigest(salt + password)

    uuid ||= SecureRandom.uuid
    User.create(
      id: uuid,
      fname: fname,
      lname: lname,
      email: email,
      password: password,
      salt: salt,
      activated: false
    )
    url = "https://school-craig.herokuapp.com/user/activate/#{uuid}?key=#{Digest::SHA256.hexdigest(salt)}"
    Mail.deliver do
      to email
      from 'sender@heroku.com'
      subject 'Account activation'
      content_type 'text/html; charset=UTF-8'
      body "Please click <a href='#{url}'>here</a> to activate your account"
    end
  else
    halt 401
  end
end

get '/user/all' do
  content_type :json
  User.all.to_json(:except => [:salt, :password])
end

post '/user/auth' do
  content_type :json
  body = request.body.read
  body = JSON.parse(body)
  email = body['email']
  password = body['password']

  user = User.find_by(email: email) || halt(401)
  user.activated || halt(403)    

  salt = user.salt
  db_password = user.password

  password = Digest::SHA256.hexdigest(salt + password)

  if db_password == password
    session[:user_id] = user.id
    user.to_json(:except => [:salt, :password, :activated])
  else
    halt 401
  end
end

post '/user/deauth' do
  session[:user_id] = nil
end

get '/user/id/:id' do |id|
  content_type :json
  begin
    User.find(id).to_json(:except => [:salt, :password])
  rescue ActiveRecord::RecordNotFound
    {}.to_json
  end
end

delete '/user/id/:id' do |id|
  unless isUUID?(id) then halt(401) end

  # deletes all associated posts
  Post.where(user_id: id).delete_all

  # checks that the user issuing the request is the user being deleted
  unless session[:user_id] == id then halt(403) end
  
  # makes sure deletion is successful
  if User.delete(id).zero? then hal(401) end
end

put '/user/id/:id' do |id|
  unless isUUID?(id) then halt(401) end

  # checks that the user issuing the request is the user being deleted
  unless session[:user_id] == id then halt(403) end

  content_type :json
  body = request.body.read
  body = JSON.parse(body)
  fname = body['fname']
  lname = body['lname']
  email = body['email']
  
  User.update(id, fname: fname, lname: lname, email: email)
end

get '/user/activate/:id' do |id|
  content_type :json
  user = User.find_by(id: id) || halt(401)
  if Digest::SHA256.hexdigest(user.salt) == params['key']
    # activates user
    user.update_attribute('activated', true)
    # logs user in
    session[:user_id] = user.id
  else
    halt 401
  end
end

