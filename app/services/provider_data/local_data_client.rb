module ProviderData
  class LocalDataClient
    def office_details(office_code)
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
  end
end
