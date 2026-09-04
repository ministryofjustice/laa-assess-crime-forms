require 'rails_helper'

RSpec.describe Auth::Strategies::AzureAd do
  subject(:result) { described_class.new(auth_hash).call }

  let(:subject_id) { SecureRandom.uuid }
  let(:email) { 'caseworker@example.com' }
  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      provider: 'azure_ad',
      uid: subject_id,
      info: { email: email, first_name: 'Case', last_name: 'Worker' }
    )
  end

  context 'with an existing Azure identity' do
    let!(:user) { create(:caseworker, auth_subject_id: subject_id, email: email) }

    it 'authenticates and refreshes the provider identity' do
      expect(result).to be_success
      expect(result.user).to eq(user)
      expect(user.authentication_identity_for('azure_ad').reload.last_authenticated_at).to be_within(1.second).of(Time.current)
      expect(user.reload.last_auth_at).to be_within(1.second).of(Time.current)
      expect(user.auth_subject_id).to eq(subject_id)
    end
  end

  context 'with a pending local invitation' do
    let!(:user) { create(:caseworker, auth_subject_id: nil, email: email) }

    it 'links the immutable Azure subject on first authentication' do
      expect(result).to be_success
      expect(user.reload.authentication_identity_for('azure_ad').subject).to eq(subject_id)
      expect(user.auth_subject_id).to eq(subject_id)
    end
  end

  context 'when the email belongs to a user with only a SiLAS identity' do
    before do
      create(:caseworker, auth_subject_id: nil, silas_user_name: 'silas-subject', email: email)
    end

    it 'fails closed instead of guessing the rollback identity' do
      expect(result).not_to be_success
      expect(result.failure_reason).to eq(:not_authorized)
    end
  end

  context 'with a deactivated user' do
    before do
      create(:caseworker, :deactivated, auth_subject_id: subject_id, email: email)
    end

    it 'fails closed' do
      expect(result).not_to be_success
      expect(result.failure_reason).to eq(:not_authorized)
    end
  end

  context 'when synchronizing the local user fails validation' do
    let!(:user) { create(:caseworker, auth_subject_id: subject_id, email: email) }

    before do
      identity = user.authentication_identity_for('azure_ad')
      allow(AuthenticationIdentity).to receive(:find_by).and_return(identity)
      allow(identity).to receive(:user).and_return(user)
      allow(user).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(user))
    end

    it 'fails closed' do
      expect(result).not_to be_success
      expect(result.failure_reason).to eq(:invalid_azure_identity)
    end
  end
end
