require 'rails_helper'

RSpec.describe Event::ChangeRisk do
  subject { described_class.build(submission:, explanation:, previous_risk_level:, current_user:) }

  let(:submission) { create(:claim, risk:) }
  let(:risk) { 'low' }
  let(:current_user) { create(:caseworker) }
  let(:previous_risk_level) { 'high' }
  let(:explanation) { 'risk has been changed' }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      submission_id: submission.id,
      submission_version: 1,
      event_type: 'Event::ChangeRisk',
      primary_user: current_user,
      details: {
        'field' => 'risk',
        'from' => previous_risk_level,
        'to' => risk,
        'comment' => explanation
      }
    )
  end

  it 'has a valid title' do
    expect(subject.title).to eq('Claim risk changed to low risk')
  end
end
