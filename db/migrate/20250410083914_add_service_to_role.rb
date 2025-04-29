class AddServiceToRole < ActiveRecord::Migration[8.0]
  def up
    add_column :roles, :service, :string

    return unless HostEnv.local? || HostEnv.development?

    User.where(email: ['super.visor@test.com', 'case.worker@test.com']).flat_map(&:roles).each do |role|
      role.update(service: 'all')
    end
  end

  def down
    remove_column :roles, :service
  end
end
