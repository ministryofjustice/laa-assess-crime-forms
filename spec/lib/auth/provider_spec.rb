require 'rails_helper'

RSpec.describe Auth::Provider do
  describe '.current' do
    before do
      allow(ENV).to receive(:fetch).and_call_original
    end

    context 'when ASSESS_AUTH_PROVIDER is not set' do
      it 'defaults to azure_ad' do
        allow(ENV).to receive(:fetch).with('ASSESS_AUTH_PROVIDER', 'azure_ad').and_return('azure_ad')

        expect(described_class.current.name).to eq('azure_ad')
      end
    end

    context 'when ASSESS_AUTH_PROVIDER is silas' do
      it 'returns silas' do
        allow(ENV).to receive(:fetch).with('ASSESS_AUTH_PROVIDER', 'azure_ad').and_return('silas')

        expect(described_class.current.name).to eq('silas')
      end
    end

    context 'when ASSESS_AUTH_PROVIDER is invalid' do
      it 'raises a clear error' do
        allow(ENV).to receive(:fetch).with('ASSESS_AUTH_PROVIDER', 'azure_ad').and_return('unknown')

        expect { described_class.current }.to raise_error(Auth::Provider::UnknownProvider, /unknown/)
      end
    end
  end

  describe '.fetch' do
    it 'encapsulates the role authority for Azure authentication' do
      provider = described_class.fetch('azure_ad')

      expect(provider.role_authority).to eq('local')
      expect(provider).to be_role_management_editable
    end

    it 'encapsulates the role authority for SiLAS authentication' do
      provider = described_class.fetch('silas')

      expect(provider.role_authority).to eq('silas')
      expect(provider).not_to be_role_management_editable
    end
  end

  describe '#accepts_callback?' do
    it 'accepts only the configured provider' do
      provider = described_class.fetch('silas')

      expect(provider.accepts_callback?(:silas)).to be true
      expect(provider.accepts_callback?(:azure_ad)).to be false
    end

    it 'accepts the local development provider in Azure mode' do
      provider = described_class.fetch('azure_ad')

      expect(provider.accepts_callback?(:dev_auth)).to be true
    end
  end

  describe '#callback_path_helper' do
    it 'returns the callback helper for the configured provider' do
      provider = described_class.fetch('silas')

      expect(provider.callback_path_helper).to eq(:user_silas_omniauth_callback_path)
    end
  end
end
