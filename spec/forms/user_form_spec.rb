require 'rails_helper'

RSpec.describe UserForm do
  describe '#save' do
    let(:user) do
      create(
        :caseworker,
        silas_user_name: 'silas-user-123',
        silas_roles: [build(:silas_role, :viewer, service: 'nsm')]
      )
    end

    it 'changes only locally managed roles' do
      form = described_class.new(
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        role_type: 'viewer',
        viewer_service: 'pa'
      )

      expect(form.save).to be(true)
      expect(user.reload.roles.pluck(:role_type, :service)).to eq([%w[viewer pa]])
      expect(user.silas_roles.pluck(:role_type, :service)).to eq([%w[viewer nsm]])
    end

    it 'removes local access without deleting an external role snapshot' do
      form = described_class.new(
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        role_type: 'none'
      )

      expect(form.save).to be(true)
      expect(user.reload.roles).to be_empty
      expect(user.silas_roles.pluck(:role_type, :service)).to eq([%w[viewer nsm]])
    end
  end
end
