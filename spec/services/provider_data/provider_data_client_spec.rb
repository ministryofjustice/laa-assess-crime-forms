require 'rails_helper'

RSpec.describe ProviderData::ProviderDataClient do
  describe '#initialize' do
    context 'when provider_api feature flag is enabled' do
      before do
        allow(FeatureFlags).to receive_message_chain(:provider_api, :enabled?).and_return(true)
      end

      it 'uses ProviderDataApiClient' do
        expect(described_class.new.instance_variable_get(:@client)).to be_a(ProviderData::ProviderDataApiClient)
      end
    end

    context 'when provider_api feature flag is disabled' do
      before do
        allow(FeatureFlags).to receive_message_chain(:provider_api, :enabled?).and_return(false)
      end

      it 'uses LocalDataClient' do
        expect(described_class.new.instance_variable_get(:@client)).to be_a(ProviderData::LocalDataClient)
      end
    end
  end
end
