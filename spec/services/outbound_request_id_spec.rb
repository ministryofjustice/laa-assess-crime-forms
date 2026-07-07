require 'rails_helper'
require 'request_store'

RSpec.describe OutboundRequestId do
  after { RequestStore.clear! }

  describe '.current' do
    it 'returns the stored request id prefixed with the service slug' do
      described_class.set('rails-request-id')

      expect(described_class.current).to eq('nscc-assess-rails-request-id')
    end

    it 'does not add the service slug twice' do
      described_class.set('nscc-assess-rails-request-id')

      expect(described_class.current).to eq('nscc-assess-rails-request-id')
    end

    it 'generates a unique NSCC Assess id when no request id is stored' do
      allow(SecureRandom).to receive(:uuid).and_return('first-uuid', 'second-uuid')

      expect(described_class.current).to eq('nscc-assess-first-uuid')
      expect(described_class.current).to eq('nscc-assess-second-uuid')
    end
  end

  describe '.headers' do
    it 'returns a request-id header' do
      described_class.set('rails-request-id')

      expect(described_class.headers).to eq('request-id' => 'nscc-assess-rails-request-id')
    end
  end
end
