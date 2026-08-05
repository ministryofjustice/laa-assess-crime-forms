require 'rails_helper'

RSpec.describe AuthenticationIdentity do
  subject(:identity) do
    described_class.new(user: user, provider: 'silas', subject: 'immutable-subject')
  end

  let(:user) { create(:caseworker) }

  it 'belongs to a user' do
    expect(described_class.reflect_on_association(:user).macro).to eq(:belongs_to)
  end

  it 'requires a subject' do
    identity.subject = nil

    expect(identity).not_to be_valid
  end

  it 'rejects an unknown provider' do
    identity.provider = 'unknown'

    expect(identity).not_to be_valid
  end

  it 'allows one identity per provider for a user' do
    identity.save!

    duplicate = described_class.new(user: user, provider: 'silas', subject: 'another-subject')

    expect(duplicate).not_to be_valid
  end

  describe '#authentication_expired?' do
    before do
      identity.last_authenticated_at = last_authenticated_at
    end

    context 'when authentication is recent' do
      let(:last_authenticated_at) { 1.hour.ago }

      it { is_expected.not_to be_authentication_expired }
    end

    context 'when authentication is older than the configured maximum' do
      let(:last_authenticated_at) { 13.hours.ago }

      it { is_expected.to be_authentication_expired }
    end

    context 'without a previous authentication timestamp' do
      let(:last_authenticated_at) { nil }

      it { is_expected.to be_authentication_expired }
    end
  end
end
