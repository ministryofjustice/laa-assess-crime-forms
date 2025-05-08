class AddServiceToRole < ActiveRecord::Migration[8.0]
  def up
    add_column :roles, :service, :string, default: 'all'
  end

  def down
    remove_column :roles, :service
  end
end
