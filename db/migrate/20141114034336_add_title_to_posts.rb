class AddTitleToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :title, :string, limit:64
  end
end
