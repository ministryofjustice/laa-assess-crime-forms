require 'rails_helper'

RSpec.describe PaymentPolicy do
  subject(:policy) { described_class.new(user, :payment) }

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

  context 'when user is a supervisor' do
    let(:user) { create(:supervisor, roles: [build(:role, :supervisor, service: 'pa')]) }

    it_behaves_like 'permits payments access'
  end

  context 'when user is a viewer' do
    let(:user) { create(:viewer, roles: [build(:role, :viewer, service: 'nsm')]) }

    it_behaves_like 'denies payments access'
  end
end
