class AddUniqueConstraintToUserEmail < ActiveRecord::Migration[8.0]
  def change
    remove_index :users, :email if index_exists?(:users, :email)
    add_index :users, :email, unique: true
  end
end
