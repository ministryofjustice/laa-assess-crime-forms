require 'rails_helper'

RSpec.describe ProviderData::ProviderDataClient do
  describe '#initialize' do
    context 'in production environment' do
      before do
        allow(Rails).to receive_message_chain(:env, :production?).and_return(true)
      end

      it 'uses ProviderDataApiClient' do
        expect(described_class.new.instance_variable_get(:@client)).to be_a(ProviderData::ProviderDataApiClient)
      end
    end

    context 'in non-production environment' do
      before do
        allow(Rails).to receive_message_chain(:env, :production?).and_return(false)
      end

      it 'uses LocalDataClient' do
        expect(described_class.new.instance_variable_get(:@client)).to be_a(ProviderData::LocalDataClient)
      end
    end
  end
end
