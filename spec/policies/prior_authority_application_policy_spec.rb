require 'rails_helper'

RSpec.describe PriorAuthorityApplicationPolicy do
  subject(:policy) { described_class.new(principal, application) }

  let(:application) do
    instance_double(PriorAuthorityApplication, assigned_user_id: user.id, state: PriorAuthorityApplication::SUBMITTED)
  end

  let(:principal) { Authorization::Principal.new(user: user, role_source: Authorization::RoleSources::Silas.new) }

  context 'with a PA caseworker role and an NSM viewer role' do
    let(:user) do
      create(
        :caseworker,
        silas_user_name: 'silas-pa-caseworker',
        silas_roles: [
          build(:silas_role, :caseworker, service: 'pa'),
          build(:silas_role, :viewer, service: 'nsm')
        ]
      )
    end

    it 'allows the user to work on an assigned PA application' do
      expect(policy.update?).to be true
      expect(policy.assign?).to be true
    end
  end

  context 'with a PA viewer role and an NSM caseworker role' do
    let(:user) do
      create(
        :caseworker,
        silas_user_name: 'silas-pa-viewer',
        silas_roles: [
          build(:silas_role, :viewer, service: 'pa'),
          build(:silas_role, :caseworker, service: 'nsm')
        ]
      )
    end

    it 'does not allow an assignment to bypass the PA viewer restriction' do
      expect(policy.update?).to be false
      expect(policy.assign?).to be false
    end
  end
end
