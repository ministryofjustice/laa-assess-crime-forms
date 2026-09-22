require 'rails_helper'

RSpec.describe User do
  describe '.active' do
    it 'includes users with an authentication identity' do
      azure_user = create(:caseworker)
      silas_user = create(:caseworker, auth_subject_id: nil, silas_user_name: 'silas-user-123')

      expect(described_class.active).to include(azure_user, silas_user)
    end

    it 'excludes pending and deactivated users' do
      pending_user = create(:caseworker, auth_subject_id: nil)
      deactivated_silas_user = create(
        :caseworker,
        :deactivated,
        auth_subject_id: nil,
        silas_user_name: 'silas-user-123'
      )

      expect(described_class.active).not_to include(pending_user, deactivated_silas_user)
    end
  end

  describe '.pending_activation' do
    it 'includes only active users without an authentication identity' do
      pending_user = create(:caseworker, auth_subject_id: nil)
      silas_user = create(:caseworker, auth_subject_id: nil, silas_user_name: 'silas-user-123')

      expect(described_class.pending_activation).to include(pending_user)
      expect(described_class.pending_activation).not_to include(silas_user)
    end
  end

  describe '#authentication_identity_for' do
    it 'returns the identity for the requested provider' do
      user = create(:caseworker, silas_user_name: 'silas-user-123')

      expect(user.authentication_identity_for('silas').subject).to eq('silas-user-123')
      expect(user.authentication_identity_for('azure_ad')).to be_present
    end

    it 'uses preloaded identities when available' do
      user = create(:caseworker, silas_user_name: 'silas-user-123')
      user.authentication_identities.load

      expect(user.authentication_identity_for('silas').subject).to eq('silas-user-123')
    end
  end

  describe '#pending_activation?' do
    it 'is true when the user has no provider identity' do
      user = build(:caseworker, auth_subject_id: nil)

      expect(user).to be_pending_activation
    end
  end

  describe '#most_recent_authentication_at' do
    let(:user) { create(:caseworker).reload }

    it 'queries the most recent provider authentication' do
      expected = AuthenticationIdentity.where(user:).maximum(:last_authenticated_at)

      expect(user.most_recent_authentication_at).to eq(expected)
    end

    it 'uses preloaded identities when available' do
      user.authentication_identities.load

      expect(user.most_recent_authentication_at)
        .to eq(user.authentication_identities.first.last_authenticated_at)
    end
  end

  describe '#auth_expired?' do
    it 'is false when maximum reauthentication time is disabled' do
      allow(Rails.configuration.x.auth).to receive(:reauthenticate_in).and_return(nil)

      expect(build(:caseworker).auth_expired?('azure_ad')).to be(false)
    end
  end
end
