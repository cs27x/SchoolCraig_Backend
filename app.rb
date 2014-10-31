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

get '/post/all' do
  if !session[:user_id] then halt(401) end
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

get '/user/all' do
  content_type :json
  User.all.to_json(:except => [:salt, :password])
end

get '/user/id/:id' do |id|
  content_type :json
  begin
    User.find(id).to_json(:except => [:salt, :password])
  rescue ActiveRecord::RecordNotFound
    {}.to_json
  end
end

post '/post' do
  content_type :json
  # parses body of post request
  body = request.body.read
  body = JSON.parse(body)
  user_id = body['user_id']
  description = body['description']

  if !(description.nil? || user_id.nil?)
    # logic for email verification goes here
    uuid = SecureRandom.uuid
    Post.create(id: uuid, user_id: user_id, description: description)
    { status: 'success' }.to_json
  else
    { status: 'failure' }.to_json
  end
end

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

    url = "/user/activate/",uuid
    Mail.deliver do
      to email
      from 'sender@heroku.com'
      subject 'Account activation'
      body  "Please click", url , "to activate your account"
    end

    salt = SecureRandom.hex
    password = Digest::SHA256.hexdigest(salt + password)

    uuid ||= SecureRandom.uuid
    User.create(
      id: uuid,
      fname: fname,
      lname: lname,
      email: email,
      password: password,
      salt: salt
    )
    { status: 'success' }.to_json
  else
    halt 401
  end
end

post '/user/auth' do
  content_type :json
  body = request.body.read
  body = JSON.parse(body)
  email = body['email']
  password = body['password']

  user = User.find_by(email: email) || halt(401)
  salt = user.salt
  db_password = user.password

  password = Digest::SHA256.hexdigest(salt + password)

  if db_password == password
    session[:user_id] = user.id
    user.to_json(:except => [:salt, :password])
  else
    halt 401
  end
end

post '/user/deauth' do
  session[:user_id] = nil
end

get '/user/activate/:id' do |id|
  content_type :json
  begin
   user = User.find_by(id: id) || halt(401)
   update_attribute('activated', true)
  end
end


