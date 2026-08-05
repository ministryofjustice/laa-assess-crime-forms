class AddSilasIdentityAndRoles < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :silas_user_name, :string
    add_column :users, :silas_roles_last_synced_at, :datetime

    add_index :users, :silas_user_name, unique: true, where: 'silas_user_name IS NOT NULL'

    create_table :silas_roles, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :role_type, null: false
      t.string :service, null: false
      t.timestamps
    end

    add_index :silas_roles, %i[user_id role_type service], unique: true
  end
end
