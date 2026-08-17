require 'rails_helper'

RSpec.describe PaymentPolicy do
  subject(:policy) { described_class.new(principal, :payment) }

  let(:principal) { Authorization::Principal.new(user:, role_source:) }
  let(:role_source) { Authorization::RoleSources::Local.new }

  shared_examples 'permits payments access' do
    it 'allows access' do
      %i[show? index? update?].each do |permission|
        expect(policy.public_send(permission)).to be(true)
      end
    end
  end

  shared_examples 'denies payments access' do
    it 'denies access' do
      %i[show? index? update?].each do |permission|
        expect(policy.public_send(permission)).to be(false)
      end
    end
  end

  context 'when user is a caseworker with NSM service' do
    let(:user) { create(:caseworker, roles: [build(:role, :caseworker, service: 'nsm')]) }

    it_behaves_like 'permits payments access'
  end

  context 'when user is a caseworker with all services' do
    let(:user) { create(:caseworker, roles: [build(:role, :caseworker, service: 'all')]) }

    it_behaves_like 'permits payments access'
  end

  context 'when user is a caseworker with PA service only' do
    let(:user) { create(:caseworker, roles: [build(:role, :caseworker, service: 'pa')]) }

    it_behaves_like 'denies payments access'
  end

  context 'when user is a supervisor with NSM service' do
    let(:user) { create(:supervisor, roles: [build(:role, :supervisor, service: 'nsm')]) }

    it_behaves_like 'permits payments access'
  end

  context 'when user is a supervisor with all services' do
    let(:user) { create(:supervisor, roles: [build(:role, :supervisor, service: 'all')]) }

    it_behaves_like 'permits payments access'
  end

  context 'when user is a supervisor with PA service only' do
    let(:user) { create(:supervisor, roles: [build(:role, :supervisor, service: 'pa')]) }

    it_behaves_like 'denies payments access'
  end

  context 'when user is a viewer' do
    let(:user) { create(:viewer, roles: [build(:role, :viewer, service: 'nsm')]) }

    it_behaves_like 'denies payments access'
  end

  context 'when user has mixed roles of caseworker PA and viewer NSM' do
    let(:user) do
      create(
        :caseworker,
        roles: [
          build(:role, :caseworker, service: 'pa'),
          build(:role, :viewer, service: 'nsm')
        ]
      )
    end

    it_behaves_like 'denies payments access'
  end

  context 'when user has mixed roles of caseworker PA and caseworker NSM' do
    let(:user) do
      create(
        :caseworker,
        roles: [
          build(:role, :caseworker, service: 'pa'),
          build(:role, :caseworker, service: 'nsm')
        ]
      )
    end

    it_behaves_like 'permits payments access'
  end

  context 'when SiLAS provides an NSM caseworker role' do
    let(:role_source) { Authorization::RoleSources::Silas.new }

    let(:user) do
      create(
        :caseworker,
        silas_user_name: 'silas-payments-caseworker',
        roles: [build(:role, :viewer, service: 'pa')],
        silas_roles: [build(:silas_role, :caseworker, service: 'nsm')]
      )
    end

    it_behaves_like 'permits payments access'
  end

  context 'when SiLAS provides a PA supervisor role' do
    let(:role_source) { Authorization::RoleSources::Silas.new }

    let(:user) do
      create(
        :supervisor,
        silas_user_name: 'silas-pa-supervisor',
        silas_roles: [build(:silas_role, :supervisor, service: 'pa')]
      )
    end

    it_behaves_like 'denies payments access'
  end
end
