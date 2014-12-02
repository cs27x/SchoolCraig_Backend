class DefaultTimestamp < ActiveRecord::Migration
  def change
    execute 'alter table "posts" alter column "date" set default CURRENT_TIMESTAMP'
  end
end
