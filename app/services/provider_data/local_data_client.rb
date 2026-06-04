module ProviderData
  class LocalDataClient
    def contracted_office_details(office_code)
      return unless office_code == '1A123B'

      {
        'firmOfficeId' => 1,
        'ccmsFirmOfficeId' => 1,
        'firmOfficeCode' => '1A123B',
        'officeName' => 'Firm & Sons',
        'officeCodeAlt' => '1A123B',
        'type' => 'Solicitor',
        'firm' => {
          'firmName' => 'Firm & Sons'
        }
      }
    end

    # rubocop:disable Metrics/MethodLength
    def office_details(office_code)
      if office_code == '1A123C'
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
      elsif office_code == '1A123D'
        {
          'firm' => {
            'advocateLevel' => nil,
            'barCouncilRoll' => nil,
            'ccmsFirmId' => 2000,
            'companyHouseNumber' => 'CMP123',
            'constitutionalStatus' => 'N/A',
            'firmId' => 1,
            'firmName' => 'NICK F CHANNING',
            'firmNumber' => '5555',
            'firmType' => 'Solicitor',
            'parentFirmId' => 3,
            'solicitorAdvocateYN' => 'Y'
          },
          'office' => {
            'addressLine1' => 'BARRISTERS-NON-PRACTISING',
            'addressLine2' => '1ST FLOOR',
            'addressLine3' => 'NEW PLACE',
            'addressLine4' => '1 RISE STREET',
            'ccmsFirmOfficeId' => 2000,
            'city' => 'LONDON',
            'cjsForceName' => 'Metropolitan',
            'county' => 'LONDON',
            'creationDate' => '2026-01-01',
            'dutySolicitorAreaName' => 'West',
            'dxCentre' => 'BROMLEY',
            'dxNumber' => '786',
            'emailAddress' => 'advocate@mail.com',
            'faxAreaCode' => '+44',
            'faxNumber' => '32313 114 55',
            'firmOfficeCode' => '1A123D',
            'firmOfficeId' => 2,
            'headOffice' => 'N/A',
            'localAuthority' => 'Bromley',
            'lscAreaOffice' => 'London',
            'lscBidZone' => 'Bromley',
            'lscRegion' => 'London',
            'officeCodeAlt' => 'NICK F CHANNING',
            'officeName' => '1A123D,BARRISTERS-NON-PRACTISING',
            'policeStationAreaName' => 'BROMLEY',
            'postCode' => 'BN1 4AB',
            'telephoneAreaCode' => '+44',
            'telephoneNumber' => '32313 114 55',
            'type' => 'Solicitor',
            'vatRegistrationNumber' => '54356'
          }
        }
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
