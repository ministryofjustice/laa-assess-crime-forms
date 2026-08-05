require 'rails_helper'

RSpec.describe Auth::SessionContext do
  subject(:context) { described_class.new(session:, configured_provider:) }

  let(:session) { {} }
  let(:configured_provider) { Auth::Provider.fetch('azure_ad') }

  describe '.bind!' do
    it 'binds a successful callback to its configured provider' do
      described_class.bind!(session, :silas)

      expect(session[described_class::SESSION_KEY]).to eq('silas')
    end

    it 'normalises the local development callback to Azure' do
      described_class.bind!(session, :dev_auth)

      expect(session[described_class::SESSION_KEY]).to eq('azure_ad')
    end
  end

  describe '#valid?' do
    context 'with a provider-bound session' do
      let(:session) { { described_class::SESSION_KEY => 'azure_ad' } }

      it { is_expected.to be_valid }
    end

    context 'with an existing Azure session created before provider binding' do
      it { is_expected.to be_valid }
    end

    context 'when the configured provider changes' do
      let(:session) { { described_class::SESSION_KEY => 'azure_ad' } }
      let(:configured_provider) { Auth::Provider.fetch('silas') }

      it { is_expected.not_to be_valid }
    end

    context 'with an unknown session provider' do
      let(:session) { { described_class::SESSION_KEY => 'unknown' } }

      it { is_expected.not_to be_valid }

      it 'does not select an authorization source' do
        expect { context.role_source }.to raise_error(Auth::Provider::UnknownProvider, /not bound/)
      end
    end
  end

  describe '#role_source' do
    let(:session) { { described_class::SESSION_KEY => 'silas' } }
    let(:configured_provider) { Auth::Provider.fetch('silas') }

    it 'builds the provider-neutral source selected at authentication' do
      expect(context.role_source).to be_a(Authorization::RoleSources::Silas)
      expect(context).not_to be_role_management_editable
    end
  end
end
