require 'rails_helper'

RSpec.describe PriorAuthority::V1::KeyInformation do
  subject(:key_information) { described_class.new(submission:) }

  let(:submission) { build(:prior_authority_application) }

  describe '#quotes_key_information_card' do
    it 'returns the quotes key information card object' do
      expect(key_information.quotes_key_information_card)
        .to be_instance_of(PriorAuthority::V1::ApplicationDetails::QuotesKeyInformationCard)
    end
  end

  describe '#key_information_card' do
    it 'delegates to quotes_key_information_card' do
      expect(key_information).to receive(:quotes_key_information_card)

      key_information.key_information_card
    end
  end
end
