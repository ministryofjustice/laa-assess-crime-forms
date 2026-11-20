require 'rails_helper'

RSpec.describe PriorAuthority::V1::ApplicationDetails::IncorrectInformationCard do
  subject(:card) { described_class.new(application_details, incorrect_information) }

  let(:application_details) { instance_double(PriorAuthority::V1::ApplicationDetails, id: '123') }
  let(:incorrect_information) do
    {
      'caseworker_id' => 'caseworker-id',
      'information_requested' => 'Correct it now',
      'sections_changed' => sections_changed,
      'requested_at' => DateTime.new(2023, 5, 2, 4, 3, 2).iso8601,
    }
  end

  describe '#provider_response' do
    let(:sections_changed) { %w[ufn case_contact primary_quote alternative_quote_1] }

    it 'links quote sections to quote adjustments and keeps overview sections as local anchors' do
      expect(card.provider_response).to include(
        'href="#overview"',
        'href="#case-contact"',
        'href="/prior_authority/applications/123/adjustments#primary-quote"',
        'href="/prior_authority/applications/123/adjustments#alternative-quote-1"',
      )
    end
  end
end
