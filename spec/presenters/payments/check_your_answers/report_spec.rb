require 'rails_helper'

RSpec.describe Payments::CheckYourAnswers::Report do
  describe '#section_groups' do
    let(:session_answers) do
      {
        'id' => SecureRandom.uuid,
        'request_type' => 'assigned_counsel',
        'date_received' => '2026-03-01',
        'solicitor_office_code' => '1A123B',
        'solicitor_firm_name' => 'Firm & Co',
        'ufn' => '120123/001',
        'defendant_last_name' => 'Doe',
        'counsel_office_code' => '2B456C',
        'counsel_firm_name' => 'Counsel Chambers'
      }
    end

    it 'includes the return_to param on the claim details change link' do
      report = described_class.new(session_answers)

      action_link = report.section_groups.dig(1, :sections, 0, :card, :actions, 0)

      expect(action_link).to include('return_to=check_your_answers')
    end
  end
end
