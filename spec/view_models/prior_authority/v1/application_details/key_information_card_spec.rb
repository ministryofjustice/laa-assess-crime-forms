require 'rails_helper'

RSpec.describe PriorAuthority::V1::ApplicationDetails::QuotesKeyInformationCard do
  subject(:key_information) { described_class.new(application_summary) }

  let(:klass) { PriorAuthority::V1::KeyInformation }
  let(:application_summary) { klass.new(args) }

  context 'when not a prison law case' do
    let(:args) do
      {
        prison_law: false,
        main_offence_id: 'robbery',
        prior_authority_granted: false,
        quotes: [
          {
            'primary' => true,
            'ordered_by_court' => true,
          },
        ],
      }
    end

    it 'shows only main offence, existing prior authority and ordered by court rows' do
      expect(key_information.card_rows.map { _1[:key][:text] }).to eq(
        [
          'Main offence',
          'Existing prior authority granted',
          'Ordered by court',
        ]
      )
      expect(key_information.card_rows.last.dig(:value, :text)).to eq('Yes')
    end
  end

  context 'when main offence is missing' do
    let(:args) do
      {
        prison_law: true,
        main_offence_id: nil,
        prior_authority_granted: false,
        quotes: [
          {
            'primary' => true,
            'ordered_by_court' => false,
          },
        ],
      }
    end

    it 'omits the main offence row' do
      rows = key_information.card_rows
      expect(rows.map { _1[:key][:text] }).to eq(
        [
          'Existing prior authority granted',
          'Ordered by court',
        ]
      )
    end
  end
end
