require 'rails_helper'

RSpec.describe ProviderData::LocalDataClient do
  describe '#contracted_office_details' do
    let(:office_code) { nil }

    context 'when office code is 1A123C' do
      let(:office_code) { '1A123C' }

      it 'returns the correct office details' do
        expect(described_class.new.contracted_office_details(office_code)).to eq(
          {
            'firmOfficeId' => 1,
            'ccmsFirmOfficeId' => 1,
            'firmOfficeCode' => '1A123C',
            'officeName' => 'Firm & Sons',
            'officeCodeAlt' => '1A123C',
            'type' => 'Solicitor'
          }
        )
      end
    end

    context 'when office code is something else' do
      let(:office_code) { 'XYZ789' }

      it 'returns nil' do
        expect(described_class.new.contracted_office_details(office_code)).to be_nil
      end
    end
  end
end
