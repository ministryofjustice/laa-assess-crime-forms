require 'rails_helper'

RSpec.describe UserManagementPolicy do
  subject(:policy) { described_class.new(principal, :user_management) }

  let(:principal) { Authorization::Principal.new(user:, role_source:) }
  let(:role_source) { Authorization::RoleSources::Silas.new }

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

  context 'when local roles provide a supervisor role for all services' do
    let(:role_source) { Authorization::RoleSources::Local.new }
    let(:user) { create(:supervisor, roles: [build(:role, :supervisor, service: 'all')]) }

    it 'allows access to user management' do
      expect(policy.show?).to be true
    end
  end

  context 'when local roles provide a supervisor role for one service' do
    let(:role_source) { Authorization::RoleSources::Local.new }
    let(:user) { create(:supervisor, roles: [build(:role, :supervisor, service: 'nsm')]) }

    it 'does not treat it as global user-management access' do
      expect(policy.show?).to be false
    end
  end

  context 'when local roles provide a caseworker role' do
    let(:role_source) { Authorization::RoleSources::Local.new }
    let(:user) { create(:caseworker, roles: [build(:role, :caseworker, service: 'all')]) }

    it 'does not allow access to user management' do
      expect(policy.show?).to be false
    end
  end

  context 'when local roles provide a viewer role' do
    let(:role_source) { Authorization::RoleSources::Local.new }
    let(:user) { create(:viewer, roles: [build(:role, :viewer, service: 'all')]) }

    it 'does not allow access to user management' do
      expect(policy.show?).to be false
    end
  end
end
