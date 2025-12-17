require 'rails_helper'

RSpec.describe ProviderData::LocalDataClient do
  describe '#office_details' do
    let(:office_code) { nil }

    context 'when office code is 1A123B' do
      let(:office_code) { '1A123B' }

      it 'returns the correct office details' do
        expect(described_class.new.office_details(office_code)).to eq({
                                                                        'firmOfficeId' => 1,
          'ccmsFirmOfficeId' => 1,
          'firmOfficeCode' => '1A123B',
          'officeName' => 'Firm & Sons',
          'officeCodeAlt' => '1A123B',
          'type' => 'Solicitor'
                                                                      })
      end
    end

    context 'when office code is something else' do
      let(:office_code) { 'XYZ789' }

      it 'returns nil' do
        expect(described_class.new.office_details(office_code)).to be_nil
      end
    end
  end
end
