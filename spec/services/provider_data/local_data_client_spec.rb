require 'rails_helper'

RSpec.describe ProviderData::LocalDataClient do
  describe '#office_details' do
    let(:office_code) { nil }

    context 'when office code is 1A123C' do
      let(:office_code) { '1A123C' }

      # rubocop:disable RSpec/ExampleLength
      it 'returns the correct office details' do
        expect(described_class.new.office_details(office_code)).to eq(
          {
            'firm' => {
              'advocateLevel' => 'Junior',
              'barCouncilRoll' => nil,
              'ccmsFirmId' => 1000,
              'companyHouseNumber' => 'CMP123',
              'constitutionalStatus' => 'N/A',
              'firmId' => 1,
              'firmName' => 'BRIAN D BECKHAM',
              'firmNumber' => '9999',
              'firmType' => 'Advocate',
              'parentFirmId' => 2,
              'solicitorAdvocateYN' => 'Y'
            },
            'office' => {
              'addressLine1' => 'BARRISTERS-NON-PRACTISING',
              'addressLine2' => '5TH FLOOR',
              'addressLine3' => 'MILLENIUM TOWER',
              'addressLine4' => '2 TOKYO STREET',
              'ccmsFirmOfficeId' => 1000,
              'city' => 'LONDON',
              'cjsForceName' => 'Metropolitan',
              'county' => 'LONDON',
              'creationDate' => '2026-01-01',
              'dutySolicitorAreaName' => 'West',
              'dxCentre' => 'BROMLEY',
              'dxNumber' => '786',
              'emailAddress' => 'advocate@mail.com',
              'faxAreaCode' => '+44',
              'faxNumber' => '10123 424 22',
              'firmOfficeCode' => '1A123C',
              'firmOfficeId' => 2,
              'headOffice' => 'N/A',
              'localAuthority' => 'Bromley',
              'lscAreaOffice' => 'London',
              'lscBidZone' => 'Bromley',
              'lscRegion' => 'London',
              'officeCodeAlt' => 'BRIAN D BECKHAM',
              'officeName' => '1A123C,BARRISTERS-NON-PRACTISING',
              'policeStationAreaName' => 'BROMLEY',
              'postCode' => 'CR0 2RJ',
              'telephoneAreaCode' => '+44',
              'telephoneNumber' => '10123 424 22',
              'type' => 'Advocate',
              'vatRegistrationNumber' => '12314'
            }
          }
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when office code is something else' do
      let(:office_code) { 'XYZ789' }

      it 'returns nil' do
        expect(described_class.new.office_details(office_code)).to be_nil
      end
    end
  end

  describe '#contracted_office_details' do
    let(:office_code) { nil }

    context 'when office code is 1A123B' do
      let(:office_code) { '1A123B' }

      it 'returns the correct office details' do
        expect(described_class.new.contracted_office_details(office_code)).to eq(
          {
            'firmOfficeId' => 1,
            'ccmsFirmOfficeId' => 1,
            'firmOfficeCode' => '1A123B',
            'officeName' => 'Firm & Sons',
            'officeCodeAlt' => '1A123B',
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
