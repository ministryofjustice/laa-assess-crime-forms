require 'rails_helper'
require 'request_store'

RSpec.describe OutboundRequestId do
  let(:hyphenated_uuid) { 'A8B0EB88-EA9A-DCAB-8902-CD521F2D5F51' }
  let(:compact_uuid) { 'a8b0eb88ea9adcab8902cd521f2d5f51' }

  after { RequestStore.clear! }

  describe '.current' do
    context 'when a request id is stored' do
      it 'normalises a hyphenated UUID' do
        described_class.set(hyphenated_uuid)

        expect(described_class.current).to eq("nscc-assess-#{compact_uuid}")
      end

      it 'normalises an uppercase compact UUID' do
        described_class.set(compact_uuid.upcase)

        expect(described_class.current).to eq("nscc-assess-#{compact_uuid}")
      end

      it 'does not add the service slug twice' do
        described_class.set("nscc-assess-#{compact_uuid.upcase}")

        expect(described_class.current).to eq("nscc-assess-#{compact_uuid}")
      end

      it 'replaces a non-UUID request id' do
        allow(SecureRandom).to receive(:uuid).and_return(hyphenated_uuid)
        described_class.set('rails-request-id')

        expect(described_class.current).to eq("nscc-assess-#{compact_uuid}")
        expect(described_class.current).to eq("nscc-assess-#{compact_uuid}")
        expect(SecureRandom).to have_received(:uuid).once
      end
    end

    context 'when no request id is stored' do
      it 'generates a unique normalised UUID for each outbound request' do
        allow(SecureRandom).to receive(:uuid).and_return(
          '11111111-2222-3333-4444-555555555555',
          'AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE',
        )

        expect(described_class.current).to eq('nscc-assess-11111111222233334444555555555555')
        expect(described_class.current).to eq('nscc-assess-aaaaaaaabbbbccccddddeeeeeeeeeeee')
      end
    end
  end

  describe '.headers' do
    it 'returns a request-id header' do
      described_class.set(hyphenated_uuid)

      expect(described_class.headers).to eq('request-id' => "nscc-assess-#{compact_uuid}")
    end
  end
end
