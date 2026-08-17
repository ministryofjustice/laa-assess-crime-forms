require 'rails_helper'

RSpec.describe Auth::Configuration do
  subject(:validate_configuration) { described_class.validate!(provider:) }

  let(:provider) { Auth::Provider.fetch('silas') }

  before do
    allow(ENV).to receive(:fetch).and_call_original
  end

  context 'when Azure AD is active' do
    let(:provider) { Auth::Provider.fetch('azure_ad') }

    it 'does not require SiLAS configuration' do
      described_class::REQUIRED_SILAS_ENV.each do |key|
        allow(ENV).to receive(:fetch).with(key, nil).and_return(nil)
      end

      expect(validate_configuration).to be(true)
    end
  end

  context 'when SiLAS is active' do
    it 'accepts complete credentials and role mappings' do
      expect(validate_configuration).to be(true)
    end

    context 'when DevAuth is enabled' do
      before do
        allow(FeatureFlags).to receive(:dev_auth).and_return(instance_double(FeatureFlags::EnabledFeature, disabled?: false))
      end

      it 'does not require external SiLAS credentials' do
        described_class::REQUIRED_SILAS_ENV.each do |key|
          allow(ENV).to receive(:fetch).with(key, nil).and_return(nil)
        end

        expect(validate_configuration).to be(true)
      end
    end

    context 'when DevAuth is disabled' do
      before do
        allow(FeatureFlags).to receive(:dev_auth).and_return(instance_double(FeatureFlags::EnabledFeature, disabled?: true))
      end

      it 'accepts complete credentials and role mappings' do
        expect(validate_configuration).to be(true)
      end

      it 'rejects missing credentials' do
        allow(ENV).to receive(:fetch).with('SILAS_ENTRA_CLIENT_SECRET', nil).and_return('')

        expect { validate_configuration }
          .to raise_error(described_class::InvalidConfiguration, /SILAS_ENTRA_CLIENT_SECRET/)
      end
    end

    it 'rejects an empty role mapping' do
      allow(ENV).to receive(:fetch).with('SILAS_ROLE_MAPPINGS', '{}').and_return('{}')

      expect { validate_configuration }
        .to raise_error(described_class::InvalidConfiguration, /SILAS_ROLE_MAPPINGS/)
    end

    it 'wraps invalid role mapping errors' do
      allow(ENV).to receive(:fetch).with('SILAS_ROLE_MAPPINGS', '{}').and_return('{invalid')

      expect { validate_configuration }
        .to raise_error(described_class::InvalidConfiguration, /Invalid SILAS_ROLE_MAPPINGS/)
    end
  end
end
