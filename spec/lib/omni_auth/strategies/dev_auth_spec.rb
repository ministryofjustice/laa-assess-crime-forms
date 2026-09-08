require 'rails_helper'
# IMPORTANT NOTE: It is possible to change the configuration used by the
# OpenID Connect strategy in a way that still functions but undermines security.
# This spec is here to make sure such changes are not made without full consideration,
# and that the Devise initializer correctly configures the OmniAuth Strategy.

describe OmniAuth::Strategies::DevAuth do
  describe 'Devise OmniAuth strategy configuration' do
    let(:strategy) { Devise.omniauth_configs.fetch(:azure_ad).strategy }

    it 'does not use the implicit flow' do
      expect(strategy.response_type).to eq(:code)
    end

    it 'Proof Key for Code Exchange (PKCE) is enabled' do
      expect(strategy.pkce).to be(true)
    end

    it 'uses the tennant url for issuer descovery' do
      expect(strategy.discovery).to be(true)
      expect(strategy.issuer).to match(
        'https://login.microsoftonline.com/TestAzureTenantID/v2.0'
      )
    end

    it 'sets the correct client options' do
      expected_options = {
        identifier: 'TestAzureClientID',
        redirect_uri: 'https://www.example.com/users/auth/azure_ad/callback',
        secret: 'TestAzureClientSecret'
      }
      expect(strategy.client_options).to match(expected_options)
    end

    it 'configures Azure and the dormant SiLAS strategy' do
      expect(Devise.omniauth_configs.keys).to contain_exactly(:azure_ad, :silas)
    end

    it 'uses the local bypass for SiLAS when dev auth is enabled' do
      expect(Devise.omniauth_configs.fetch(:silas).strategy_class).to eq(described_class)
    end
  end

  describe 'SiLAS claim simulation' do
    subject(:claims) { strategy.send(:silas_claims) }

    let(:strategy) { described_class.new(nil, name: :silas) }
    let(:email) { 'case.worker@example.com' }
    let(:request) { instance_double(Rack::Request, params: { 'email' => email }) }

    before do
      allow(strategy).to receive(:request).and_return(request)
    end

    context 'when the local user has no SiLAS snapshot' do
      before do
        create(
          :caseworker,
          email: email,
          silas_user_name: nil,
          roles: [build(:role, :caseworker, service: 'all')]
        )
      end

      it 'generates deterministic identity and role claims from local data' do
        expect(claims).to eq(
          'USER_NAME' => "silas-#{email}",
          'USER_EMAIL' => email,
          'LAA_APP_ROLES' => ['Assess Caseworker (All)']
        )
      end
    end

    context 'when no local user matches the email' do
      let(:email) { described_class::NO_AUTH_EMAIL }

      it 'keeps the identity and role claims empty' do
        expect(claims).to eq(
          'USER_NAME' => nil,
          'USER_EMAIL' => email,
          'LAA_APP_ROLES' => []
        )
      end
    end

    context 'when the local role cannot be mapped' do
      before do
        create(
          :supervisor,
          email: email,
          silas_user_name: nil,
          roles: [build(:role, :supervisor, service: 'nsm')]
        )
      end

      it 'emits an empty role claim' do
        expect(claims['LAA_APP_ROLES']).to eq([])
      end
    end

    context 'when the role mapping configuration is invalid' do
      before do
        create(:caseworker, email: email, silas_user_name: nil)
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('SILAS_ROLE_MAPPINGS', '{}').and_return('{invalid')
      end

      it 'emits an empty role claim' do
        expect(claims['LAA_APP_ROLES']).to eq([])
      end
    end
  end
end
