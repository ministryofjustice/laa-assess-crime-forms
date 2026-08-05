require 'rails_helper'

RSpec.describe UserManagementPolicy do
  subject(:policy) { described_class.new(principal, :user_management) }

  let(:principal) { Authorization::Principal.new(user: user, role_source: Authorization::RoleSources::Silas.new) }

  context 'when SiLAS provides a supervisor role for all services' do
    let(:user) do
      create(
        :supervisor,
        silas_user_name: 'silas-global-supervisor',
        silas_roles: [build(:silas_role, :supervisor, service: 'all')]
      )
    end

    it 'allows access to global user management' do
      expect(policy.show?).to be true
    end
  end

  context 'when SiLAS provides a supervisor role for one service' do
    let(:user) do
      create(
        :supervisor,
        silas_user_name: 'silas-nsm-supervisor',
        silas_roles: [build(:silas_role, :supervisor, service: 'nsm')]
      )
    end

    it 'does not treat it as global user-management access' do
      expect(policy.show?).to be false
    end
  end
end
