require 'rails_helper'

RSpec.describe Auth::UserAuthenticator do
  describe '.call' do
    subject(:result) { described_class.call(auth_hash) }

    context 'when the provider is azure_ad' do
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: 'azure_ad',
          uid: SecureRandom.uuid,
          info: { email: 'caseworker@example.com' }
        )
      end

      let!(:user) { create(:caseworker, auth_subject_id: auth_hash.uid) }

      it 'authenticates with the Azure strategy' do
        expect(result).to be_success
        expect(result.user).to eq(user)
      end
    end

    context 'when the provider is a symbol' do
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: :azure_ad,
          uid: SecureRandom.uuid,
          info: { email: 'caseworker@example.com' }
        )
      end

      let!(:user) { create(:caseworker, auth_subject_id: auth_hash.uid) }

      it 'normalises the provider before dispatching' do
        expect(result).to be_success
        expect(result.user).to eq(user)
      end
    end

    context 'when the provider is silas' do
      before do
        allow(Auth::Provider).to receive(:current).and_return(Auth::Provider.fetch('silas'))
      end

      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: 'silas',
          uid: SecureRandom.uuid,
          info: {
            email: 'caseworker@example.com',
            first_name: 'Case',
            last_name: 'Worker'
          },
          extra: {
            raw_info: {
              'USER_NAME' => 'silas-user-123',
              'USER_EMAIL' => 'caseworker@example.com',
              'LAA_APP_ROLES' => ['Assess Caseworker (All)']
            }
          }
        )
      end

      let!(:user) do
        create(:caseworker, email: 'caseworker@example.com', silas_user_name: 'silas-user-123')
      end

      it 'authenticates with the SiLAS strategy' do
        expect(result).to be_success
        expect(result.user).to eq(user)
        expect(user.reload.authentication_identity_for('silas').subject).to eq('silas-user-123')
      end
    end

    context 'when the provider is dev_auth' do
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: 'dev_auth',
          uid: SecureRandom.uuid,
          info: { email: 'caseworker@example.com' }
        )
      end

      let!(:user) { create(:caseworker, auth_subject_id: auth_hash.uid) }

      it 'uses the Azure-compatible strategy for local development' do
        expect(result).to be_success
        expect(result.user).to eq(user)
      end
    end

    context 'when the provider is unsupported' do
      let(:auth_hash) { OmniAuth::AuthHash.new(provider: 'other', uid: SecureRandom.uuid, info: {}) }

      it 'fails closed' do
        expect(result).not_to be_success
        expect(result.user).to be_nil
        expect(result.failure_reason).to eq(:unsupported_provider)
      end
    end

    context 'when the provider does not match the configured provider' do
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: 'silas',
          uid: SecureRandom.uuid,
          info: {},
          extra: { raw_info: {} }
        )
      end

      it 'fails closed before invoking the inactive provider' do
        expect(result).not_to be_success
        expect(result.failure_reason).to eq(:provider_mismatch)
      end
    end
  end
end
