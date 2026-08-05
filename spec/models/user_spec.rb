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
  end

  describe '#pending_activation?' do
    it 'is true when the user has no provider identity' do
      user = build(:caseworker, auth_subject_id: nil)

      expect(user).to be_pending_activation
    end
  end
end
