require 'rails_helper'

RSpec.describe Payments::CheckYourAnswers::Report do
  subject(:report) { described_class.new('id' => submission_id) }

  let(:submission_id) { SecureRandom.uuid }

  describe '#actions' do
    let(:card) do
      double(
        'card',
        read_only?: false,
        change_link_controller_path: 'payments/steps/claim_search',
        change_link_controller_method: :edit,
        change_link_query_params: { return_to: 'check_your_answers' }
      )
    end

    before do
      allow(report).to receive(:govuk_link_to) { |_label, url| url }
    end

    it 'includes the change-link query params in the generated url' do
      actions = report.send(:actions, card)

      expect(actions.length).to eq(1)
      expect(actions.first).to include(submission_id)
      expect(actions.first).to include('claim_search')
      expect(actions.first).to include('return_to=check_your_answers')
    end
  end
end
