require 'rails_helper'

RSpec.describe Payments::CheckYourAnswers::Report do
  describe '#claim_details_section' do
    let(:session_answers) { { 'request_type' => 'unsupported_request_type' } }

    it 'returns false for unsupported request types' do
      expect(described_class.new(session_answers).claim_details_section).to be(false)
    end
  end
end
