SchoolCraig_Backend
===================

Backend for the SchoolCraig project

* Swagger docs for API use can be found at: https://school-craig.herokuapp.com/swagger/dist/index.html

Routes (Users)
--------------

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

Routes (Posts)
--------------

`
post '/post', body = { 'id' => post_uuid, 'user_id' => @user_uuid, 'title' => 'Bike for sale', 'description' => 'New bike', 'category_id' => @category_uuid, 'cost' => '10' }.to_json
`
  - Creates a new post with the given title, description, and cost

`
put "/post/id/#{post_uuid}" , body = { 'title' => 'New Bike for sale', 'description' => 'One New bike', 'cost' => '20' }.to_json
`
  - Modifies a post by specific ID with given title, description, and cost (none are needed)

`
 get "/post/id/#{post_uuid}"
`
  - Gets a post with the given UUID

`
get '/post/all'
`
  - Lists all posts

`
delete "/post/id/#{post_uuid}"
`
  - Deletes a post with the given UUID

Routes (Categories)
-------------------

`
get "/category/id/#{@category_uuid}
`
  - Display a category by ID

`
get '/category/all'
`
  - List all categories

`
post '/category', body = { 'id' => @category_uuid, 'name' => 'Furniture' }.to_json
`
  - Creates a new category with the given name
  
