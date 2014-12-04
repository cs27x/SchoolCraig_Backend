SchoolCraig_Backend
===================

Backend for the SchoolCraig project

* Swagger docs for API use can be found at: https://school-craig.herokuapp.com/swagger/dist/index.html

Routes
------

Sinatra routes are a HTTP method paired with a URL matching pattern.
Here is an example from app_test.rb:

  ```
@user_uuid = SecureRandom.uuid
post '/user', body = { 'id' => @user_uuid, 'fname' => 'Alex' , 'lname' => 'Smith', 'email' => 'test@vanderbilt.edu', 'password' => 'pwd' }.to_json
  ```

The above code writes a new user to the database with the provided name, e-mail and password. A UUID is generated at random for the created user. The body is turned into a JSON string before being written to the database. If successful, a code of 200 is returned. Here is another user route:

`
post '/user/auth', body = { 'email' => 'test@vanderbilt.edu', 'password' => 'pwd' }.to_json
`

The above code authenticates the same user and establishes a session if the credentials match. Otherwise, a code of 401 is returned.

Other user routes include:

`
put "/user/id/#{@user_uuid}", body = {'fname' => 'Alexander' , 'lname' => 'Smithy'}.to_json
`
  - Modifies the user based on the UUID, in this case we changed the user's first and last name
  
`
get "/user/id/#{@user_uuid}"
`
  - Lists a specific user
  
`
get "/user/id/#{@user_uuid}"
`
  - Lists all users
  
`
delete "/user/id/#{@user_uuid}"
`
  - Removes a specific user
  
`
post '/user/deauth'
`
  - Ends current session
