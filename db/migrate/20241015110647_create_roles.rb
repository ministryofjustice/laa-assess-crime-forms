class CreateRoles < ActiveRecord::Migration[7.1]
  def up
    create_table :roles do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :role_type

      t.timestamps
    end

    User.find_each do |user|
      user.roles.create! role_type: user.role
    end

    remove_column :users, :role, :string
  end

  def down
    add_column :users, :role, :string

    User.find_each do |user|
      user.update!(role: user.roles.first.role_type)
    end

    drop_table :roles
  end
end
