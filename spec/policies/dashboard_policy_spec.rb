require 'rails_helper'

RSpec.describe DashboardPolicy do
  subject(:policy) { described_class.new(principal, :dashboard) }

  let(:principal) { Authorization::Principal.new(user:, role_source:) }
  let(:role_source) { Authorization::RoleSources::Local.new }

  context 'when a supervisor has all-service access' do
    let(:user) { create(:supervisor, roles: [build(:role, :supervisor, service: 'all')]) }

    it { is_expected.to be_show }
  end

  context 'when a supervisor has both service-specific roles' do
    let(:user) do
      create(
        :supervisor,
        roles: [
          build(:role, :supervisor, service: 'pa'),
          build(:role, :supervisor, service: 'nsm')
        ]
      )
    end

    it { is_expected.to be_show }
  end

  context 'when a supervisor has only one service-specific role' do
    let(:user) { create(:supervisor, roles: [build(:role, :supervisor, service: 'nsm')]) }

    it { is_expected.not_to be_show }
  end

  context 'when SiLAS supplies only a PA supervisor role' do
    let(:role_source) { Authorization::RoleSources::Silas.new }
    let(:user) do
      create(
        :supervisor,
        silas_user_name: 'silas-pa-supervisor',
        silas_roles: [build(:silas_role, :supervisor, service: 'pa')]
      )
    end

    it { is_expected.not_to be_show }
  end
end
