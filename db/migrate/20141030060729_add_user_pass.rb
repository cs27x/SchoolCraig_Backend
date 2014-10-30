class AddUserPass < ActiveRecord::Migration
  def change
    add_column :users, :password, :string, limit: 64
    add_column :users, :salt, :string, limit: 32
  end
end
