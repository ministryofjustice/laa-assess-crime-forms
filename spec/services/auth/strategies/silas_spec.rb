require 'rails_helper'

RSpec.describe Auth::Strategies::Silas do
  describe '#call' do
    subject(:result) { described_class.new(auth_hash).call }

    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: 'silas',
        uid: 'entra-subject',
        info: {
          email: email,
          first_name: 'Sally',
          last_name: 'Silas'
        },
        extra: {
          raw_info:
        }
      )
    end

    let(:email) { 'sally.silas@example.com' }
    let(:raw_info) do
      {
        'USER_NAME' => 'silas-uuid',
        'USER_EMAIL' => email,
        'LAA_APP_ROLES' => ['Assess Caseworker (NSM)']
      }
    end

    context 'when an active user already has the SiLAS identifier' do
      let!(:user) { create(:caseworker, email: email, silas_user_name: 'silas-uuid') }

      it 'finds the user by SiLAS identifier and syncs SiLAS roles' do
        expect(result).to be_success
        expect(result.user).to eq(user)
        expect(user.reload.silas_roles.pluck(:role_type, :service)).to eq([%w[caseworker nsm]])
        expect(user.authentication_identity_for('silas').roles_synced_at).to be_within(1.second).of(Time.current)
        expect(user.silas_roles_last_synced_at).to be_within(1.second).of(Time.current)
        expect(user.last_auth_at).to be_within(1.second).of(Time.current)
      end
    end

    context 'when an existing Azure user has the same email but no SiLAS identifier' do
      let(:email) { 'sally.silas@example.com' }
      let!(:user) do
        create(
          :caseworker,
          email: 'Sally.Silas@example.com',
          roles: [build(:role, :viewer, service: 'pa')]
        )
      end
      let(:azure_identity) { user.authentication_identity_for('azure_ad') }
      let(:azure_subject) { azure_identity.subject }

      it 'links the verified email to USER_NAME and preserves the Azure rollback identity' do
        expect(result).to be_success
        expect(result.user).to eq(user)

        reloaded_user = user.reload
        expect(reloaded_user.authentication_identity_for('silas').subject).to eq('silas-uuid')
        expect(reloaded_user.authentication_identity_for('azure_ad').subject).to eq(azure_subject)
        expect(reloaded_user.roles.pluck(:role_type, :service)).to eq([%w[viewer pa]])
      end

      it 'can authenticate through the original Azure identity after linking SiLAS' do
        expect(result).to be_success

        azure_auth_hash = OmniAuth::AuthHash.new(
          provider: 'azure_ad',
          uid: azure_subject,
          info: { email: user.email, first_name: user.first_name, last_name: user.last_name }
        )
        azure_result = Auth::Strategies::AzureAd.new(azure_auth_hash).call

        expect(azure_result).to be_success
        expect(azure_result.user).to eq(user)
        expect(user.reload.roles.pluck(:role_type, :service)).to eq([%w[viewer pa]])
      end
    end

    context 'when the email is already linked to a different SiLAS identifier' do
      let!(:user) { create(:caseworker, email: email, silas_user_name: 'different-silas-user') }

      it 'fails closed without replacing the existing identity' do
        expect(result).not_to be_success
        expect(result.failure_reason).to eq(:unknown_silas_user)
        expect(user.reload.authentication_identity_for('silas').subject).to eq('different-silas-user')
      end
    end

    context 'when the SiLAS user is not already known locally' do
      it 'fails closed rather than provisioning an unagreed identity' do
        expect { result }.not_to change(User, :count)
        expect(result).not_to be_success
        expect(result.failure_reason).to eq(:unknown_silas_user)
      end
    end

    context 'when the matching user is deactivated' do
      before do
        create(:caseworker, :deactivated, email: email, silas_user_name: 'silas-uuid')
      end

      it 'fails closed' do
        expect(result).not_to be_success
        expect(result.user).to be_nil
        expect(result.failure_reason).to eq(:user_deactivated)
      end
    end

    context 'when a deactivated Azure user has the same email but no SiLAS identifier' do
      let!(:user) { create(:caseworker, :deactivated, email:) }

      it 'fails closed without linking the identity' do
        expect(result).not_to be_success
        expect(result.failure_reason).to eq(:user_deactivated)
        expect(user.reload.authentication_identity_for('silas')).to be_nil
      end
    end

    context 'when the verified email already belongs to another user' do
      let!(:user) do
        create(:caseworker, email: 'old.email@example.com', silas_user_name: 'silas-uuid')
      end

      before do
        create(:caseworker, email:)
      end

      it 'fails closed without partially updating the matched user' do
        expect(result).not_to be_success
        expect(result.failure_reason).to eq(:invalid_silas_identity)
        expect(user.reload.email).to eq('old.email@example.com')
        expect(user.silas_roles).to be_empty
      end
    end

    context 'when USER_NAME is missing' do
      let(:raw_info) { { 'USER_EMAIL' => email, 'LAA_APP_ROLES' => ['Assess Caseworker (NSM)'] } }

      it 'fails closed' do
        expect(result).not_to be_success
        expect(result.failure_reason).to eq(:missing_silas_user_name)
      end
    end

    context 'when USER_EMAIL is missing' do
      let(:raw_info) { { 'USER_NAME' => 'silas-uuid', 'LAA_APP_ROLES' => ['Assess Caseworker (NSM)'] } }

      it 'fails closed' do
        expect(result).not_to be_success
        expect(result.failure_reason).to eq(:missing_silas_email)
      end
    end

    context 'when USER_NAME is not a string' do
      let(:raw_info) do
        {
          'USER_NAME' => 123,
          'USER_EMAIL' => email,
          'LAA_APP_ROLES' => ['Assess Caseworker (NSM)']
        }
      end

      it 'fails closed' do
        expect(result).not_to be_success
        expect(result.failure_reason).to eq(:invalid_silas_user_name)
      end
    end

    context 'when USER_EMAIL is not a string' do
      let(:raw_info) do
        {
          'USER_NAME' => 'silas-uuid',
          'USER_EMAIL' => { 'value' => email },
          'LAA_APP_ROLES' => ['Assess Caseworker (NSM)']
        }
      end

      it 'fails closed' do
        expect(result).not_to be_success
        expect(result.failure_reason).to eq(:invalid_silas_email)
      end
    end

    context 'when USER_EMAIL is not a valid email address' do
      let(:email) { 'not-an-email-address' }

      it 'fails closed' do
        expect(result).not_to be_success
        expect(result.failure_reason).to eq(:invalid_silas_email)
      end
    end

    context 'when roles are missing' do
      let(:raw_info) { { 'USER_NAME' => 'silas-uuid', 'USER_EMAIL' => email, 'LAA_APP_ROLES' => [] } }

      it 'fails closed' do
        expect(result).not_to be_success
        expect(result.failure_reason).to eq(:invalid_silas_roles)
      end
    end

    context 'when raw claim data has an invalid shape' do
      let(:raw_info) { 'not-a-claim-object' }

      it 'fails closed' do
        expect(result).not_to be_success
        expect(result.failure_reason).to eq(:missing_silas_user_name)
      end
    end

    context 'when a role value is not a string' do
      let(:raw_info) do
        {
          'USER_NAME' => 'silas-uuid',
          'USER_EMAIL' => email,
          'LAA_APP_ROLES' => ['Assess Caseworker (NSM)', 123]
        }
      end

      it 'fails closed' do
        expect(result).not_to be_success
        expect(result.failure_reason).to eq(:invalid_silas_roles)
      end
    end
  end
end
