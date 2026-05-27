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
        'type' => 'Solicitor'
      }
    end

    # rubocop:disable Metrics/MethodLength
    def office_details(office_code)
      return unless office_code == '1A123C'

      {
        'office' => {
          'firmOfficeId' => 1,
          'ccmsFirmOfficeId' => 1,
          'firmOfficeCode' => '1A123C',
          'officeName' => 'Firm & Sons',
          'officeCodeAlt' => '1A123C',
          'type' => 'Legal Services Supplier (Civil/Crime/Both/Mediator)'
        },
        'firm' => {
          'advocateLevel' => 'Junior',
            'barCouncilRoll' => 'Test',
            'ccmsFirmId' => 123,
            'companyHouseNumber' => 'ABD',
            'constitutionalStatus' => 'Limited Company',
            'firmId' => 1,
            'firmName' => 'Counsel & Sons',
            'firmNumber' => '987',
            'firmType' => 'Legal Services Provider',
            'parentFirmId' => 2,
            'solicitorAdvocateYN' => 'N'
        }
      }
    end
    # rubocop:enable Metrics/MethodLength
  end
end
