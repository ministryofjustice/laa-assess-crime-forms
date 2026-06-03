require 'rails_helper'

RSpec.describe ProviderData::ProviderDataApiClient do
  describe '#office_details' do
    let(:office_code) { '1A123C' }
    let(:api_response) { nil }
    let(:api_url) { "https://provider-api.example.com/provider-offices/#{office_code}" }
    let(:response) { double(:response, code:, body:) }
    let(:code) { nil }
    let(:body) { nil }

    before do
      allow(ENV).to receive(:fetch).and_call_original
      stub_request(:get, api_url).to_return(status: code, body: body)
    end

    context 'when there are office details returned' do
      let(:code) { 200 }
      let(:body) do
        {
          'office' => {
            'firmOfficeId' => 1,
            'ccmsFirmOfficeId' => 1,
            'firmOfficeCode' => '1A123C',
            'officeName' => 'Smith & Co',
            'officeCodeAlt' => '1A123C',
            'type' => 'Solicitor'
          },
          'firm' => {
            'firmId' => 1,
            'ccmsFirmId' => 1,
            'firmName' => 'Smith & Co',
            'sraNumber' => '12345678'
          }
        }.to_json
      end

      it 'returns the correct office and firm details' do
        expect(described_class.office_details(office_code)).to eq(
          {
            'office' => {
              'firmOfficeId' => 1,
              'ccmsFirmOfficeId' => 1,
              'firmOfficeCode' => '1A123C',
              'officeName' => 'Smith & Co',
              'officeCodeAlt' => '1A123C',
              'type' => 'Solicitor'
            },
            'firm' => {
              'firmId' => 1,
              'ccmsFirmId' => 1,
              'firmName' => 'Smith & Co',
              'sraNumber' => '12345678'
            }
          }
        )
      end
    end
  end

  describe '#contracted_office_details' do
    let(:office_code) { '1A123B' }
    let(:api_response) { nil }
    let(:api_url) { "https://provider-api.example.com/provider-offices/#{office_code}/schedules?areaOfLaw=CRIME%20LOWER" }
    let(:response) { double(:response, code:, body:) }
    let(:code) { nil }
    let(:body) { nil }

    before do
      allow(ENV).to receive(:fetch).and_call_original
      stub_request(:get, api_url).to_return(status: code, body: body)
    end

    context 'when running locally' do
      before do
        allow(HostEnv).to receive(:uat?).and_return(false)
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
            },
            'firm' => {
              'firmId' => 1,
              'ccmsFirmId' => 1,
              'firmName' => 'Correct Firm Name',
              'sraNumber' => '12345678'
            }
          }.to_json
        end

        it 'returns the correct office details' do
          expect(described_class.contracted_office_details(office_code)).to eq(
            {
              'firmOfficeId' => 1,
              'ccmsFirmOfficeId' => 1,
              'firmOfficeCode' => '1A123B',
              'officeName' => 'Firm & Sons',
              'officeCodeAlt' => '1A123B',
              'type' => 'Solicitor',
              'firm' => {
                'firmId' => 1,
                'ccmsFirmId' => 1,
                'firmName' => 'Correct Firm Name',
                'sraNumber' => '12345678'
              }
            }
          )
        end
      end

      context 'when there are no office details returned' do
        let(:code) { 204 }
        let(:body) { {}.to_json }

        it 'returns nil' do
          expect(described_class.contracted_office_details(office_code)).to be_nil
        end
      end

      context 'when an unexpected status code is returned' do
        let(:code) { 500 }
        let(:body) { {}.to_json }

        it 'raises an error' do
          expect do
            described_class.contracted_office_details(office_code)
          end.to raise_error(StandardError, /Unexpected status code 500/)
        end
      end
    end

    context 'when running in UAT environment' do
      let(:api_url) { "https://provider-api.example.com/provider-offices/#{office_code}/schedules?areaOfLaw=CRIME+LOWER&effectiveDate=01-01-2025" }
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
          },
          'firm' => {
            'firmId' => 1,
            'ccmsFirmId' => 1,
            'firmName' => 'Correct Firm Name',
            'sraNumber' => '12345678'
          }
        }.to_json
      end

      before do
        allow(HostEnv).to receive(:uat?).and_return(true)
        stub_request(:get, api_url).to_return(status: code, body: body)
      end

      it 'requests the correct URL with effective date' do
        described_class.contracted_office_details(office_code)
        expect(WebMock).to have_requested(:get, api_url)
      end
    end
  end
end
