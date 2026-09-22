require 'rails_helper'

RSpec.describe ClaimPolicy do
  subject(:policy) { described_class.new(principal, claim) }

  let(:claim) { instance_double(Claim, assigned_user_id: user.id, closed?: false) }
  let(:principal) { Authorization::Principal.new(user: user, role_source: Authorization::RoleSources::Silas.new) }

  context 'with an NSM caseworker role and a PA viewer role' do
    let(:user) do
      create(
        :caseworker,
        silas_user_name: 'silas-caseworker',
        silas_roles: [
          build(:silas_role, :caseworker, service: 'nsm'),
          build(:silas_role, :viewer, service: 'pa')
        ]
      )
    end

    it 'allows the user to work on an assigned NSM claim' do
      expect(policy.update?).to be true
      expect(policy.assign?).to be true
    end
  end

  context 'with an NSM viewer role and a PA caseworker role' do
    let(:user) do
      create(
        :caseworker,
        silas_user_name: 'silas-viewer',
        silas_roles: [
          build(:silas_role, :viewer, service: 'nsm'),
          build(:silas_role, :caseworker, service: 'pa')
        ]
      )
    end

    it 'does not allow an assignment to bypass the NSM viewer restriction' do
      expect(policy.update?).to be false
      expect(policy.assign?).to be false
    end
  end
end
