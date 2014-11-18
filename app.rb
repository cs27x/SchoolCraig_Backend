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
set :force_ssl, true

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

before do
  content_type :json
end


########## /category #############
get '/category/all' do
  Category.all.to_json
end

get '/category/id/:id' do |id|
  unless isUUID?(id) then halt(401) end
  begin
    Category.find(id).to_json
  rescue ActiveRecord::RecordNotFound
    {}.to_json
  end
end

post '/category' do
  unless session[:user_id] then halt(403) end
  # parses body of post request
  body = request.body.read
  body = JSON.parse(body)
  id = body['id'] || SecureRandom.uuid
  unless isUUID?(id) then halt(401) end
  name = body['name']
  if Category.find_by(name: name) then halt(401) end

  name ? Category.create(id: id, name: name) : halt(401)
end


########## /post #############
post '/post' do
  # parses body of post request
  body = request.body.read
  body = JSON.parse(body)
  id = body['id'] || SecureRandom.uuid
  user_id = body['user_id']
  unless session[:user_id] == user_id then halt(403) end
  title = body['title']
  description = body['description']
  category_id = body['category_id']
  cost = body['cost'] || 0
  
  [id, user_id, category_id].compact.each do |x| 
    unless isUUID?(x) then halt(401) end
  end

  if [description, title].all?
    # logic for email verification goes here
    Post.create(id: id, user_id: user_id, title: title, description: description, category_id: category_id, cost: cost)
  else
    halt 401
  end
end

get '/post/all' do
  puts JSON.pretty_generate(request.env)
  unless session[:user_id] then halt(403) end
  Post.all.to_json
end

delete '/post/id/:id' do |id|
  # makes sure post with id exists
  mypost = Post.find_by(id: id) || halt(401)
  # makes sure user owns the post
  unless mypost.user_id == session[:user_id] then halt(403) end
  
  unless isUUID?(id) then halt(401) end
  if Post.delete(id).zero? then halt(401) end
end

put '/post/id/:id' do |id|
  # makes sure id is a uuid
  unless isUUID?(id) then halt(401) end
  # makes sure post with id exists
  mypost = Post.find_by(id: id) || halt(401)
  # makes sure user owns the post
  unless mypost.user_id == session[:user_id] then halt(403) end

  # parses body of request
  body = request.body.read
  body = JSON.parse(body)
  title = body['title']
  description = body['description']
  cost = body['cost']
 
  if [description, title].all?
    Post.update(id, title: title, description: description, cost: cost)
  else
    halt 401
  end 
end

get '/post/id/:id' do |id|
  unless session[:user_id] then halt(403) end
  unless isUUID?(id) then halt(401) end
  begin
    Post.find(id).to_json
  rescue ActiveRecord::RecordNotFound
    halt 404
  end
end

########## /user #############
post '/user' do
  # parses body of post request
  body = request.body.read
  body = JSON.parse(body)
  uuid = body['id'] || SecureRandom.uuid
  fname = body['fname']
  lname = body['lname']
  email = body['email']
  password = body['password']

  if [fname, lname, email, password].all? && isUUID?(uuid)
    salt = SecureRandom.hex
    password = Digest::SHA256.hexdigest(salt + password)
    activated = settings.environment == :development

    User.create(
      id: uuid,
      fname: fname,
      lname: lname,
      email: email,
      password: password,
      salt: salt,
      activated: activated
    )
    unless activated
      url = "https://school-craig.herokuapp.com/user/activate/#{uuid}?key=#{Digest::SHA256.hexdigest(salt)}"
      Mail.deliver do
        to email
        from 'sender@heroku.com'
        subject 'Account activation'
        content_type 'text/html; charset=UTF-8'
        body "Please click <a href='#{url}'>here</a> to activate your account"
      end
    end
  else
    halt 401
  end
end

get '/user/all' do
  unless session[:user_id] then halt(403) end
  User.all.to_json(:except => [:salt, :password])
end

post '/user/auth' do
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
  session.clear
end

get '/user/id/:id' do |id|
  unless session[:user_id] then halt(403) end
  begin
    User.find(id).to_json(:except => [:salt, :password])
  rescue ActiveRecord::RecordNotFound
    halt 404
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

  # checks that the user issuing the request is the user being modified
  unless session[:user_id] == id then halt(403) end

  body = request.body.read
  body = JSON.parse(body)
  fname = body['fname']
  lname = body['lname']
  
  User.update(id, fname: fname, lname: lname)
end

get '/user/activate/:id' do |id|
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
