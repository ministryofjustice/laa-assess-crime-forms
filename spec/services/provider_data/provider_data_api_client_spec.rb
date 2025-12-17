require 'rails_helper'

RSpec.describe ProviderData::ProviderDataApiClient do
  describe '#office_details' do
    let(:office_code) { '1A123B' }
    let(:api_response) { nil }
    let(:api_url) { "https://provider-api.example.com/provider-offices/#{office_code}/schedules?areaOfLaw=CRIME%20LOWER" }
    let(:response) { double(:response, code:, body:) }
    let(:code) { nil }
    let(:body) { nil }

    before do
      allow(ENV).to receive(:fetch).and_call_original
      stub_request(:head, api_url).to_return(status: code, body: body)
    end

    context 'when there are office details returned' do
      let(:code) { 200 }
      let(:body) do
        {
          'office' => {
            'firmOfficeId' => 1,
            'ccmsFirmOfficeId' => 1,
            'firmOfficeCode' => '1A123B',
            'officeName' => 'Firm & Sons',
            'officeCodeAlt' => '1A123B',
            'type' => 'Solicitor'
          }
        }.to_json
      end

      it 'returns the correct office details' do
        expect(described_class.office_details(office_code)).to eq({
                                                                    'firmOfficeId' => 1,
          'ccmsFirmOfficeId' => 1,
          'firmOfficeCode' => '1A123B',
          'officeName' => 'Firm & Sons',
          'officeCodeAlt' => '1A123B',
          'type' => 'Solicitor'
                                                                  })
      end
    end

    context 'when there are no office details returned' do
      let(:code) { 204 }
      let(:body) { {}.to_json }

      it 'returns nil' do
        expect(described_class.office_details(office_code)).to be_nil
      end
    end

    context 'when an unexpected status code is returned' do
      let(:code) { 500 }
      let(:body) { {}.to_json }

      it 'raises an error' do
        expect { described_class.office_details(office_code) }.to raise_error(StandardError, /Unexpected status code 500/)
      end
    end
  end
end
