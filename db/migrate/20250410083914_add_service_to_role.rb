class AddServiceToRole < ActiveRecord::Migration[8.0]
  def up
    add_column :roles, :service, :string

    if Rails.env.local?
      User.where(email: ['super.visor@test.com', 'case.worker@test.com']).flat_map(&:roles).each do |role|
        role.update(service: 'all')
      end
    elsif Rails.env.production?
      Rails.logger.info('hello')
    end
  end

  def down
    remove_column :roles, :service
  end
end
