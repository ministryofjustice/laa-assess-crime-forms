require 'rails_helper'

RSpec.describe 'History events' do
  let(:caseworker) { create(:caseworker) }
  let(:claim) { create(:claim) }
  let(:fixed_arbitrary_date) { Time.zone.local(2023, 2, 1, 9, 0) }

  before do
    claim
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'
  end

  it 'shows all (visible) events in the history' do
    supervisor = create(:supervisor)

    Event::NewVersion.build(submission: claim)
    Event::Assignment.build(submission: claim, current_user: caseworker)
    Event::Unassignment.build(submission: claim, user: caseworker, current_user: caseworker,
                              comment: 'unassignment 1')
    Event::Assignment.build(submission: claim, current_user: caseworker, comment: 'Manual assignment note')
    Event::ChangeRisk.build(submission: claim, explanation: 'Risk change test', previous_risk_level: 'high',
                            current_user: caseworker)
    Event::Note.build(submission: claim, current_user: caseworker, note: 'User test note')
    claim.state = 'sent_back'
    Nsm::Event::SendBack.build(submission: claim, current_user: caseworker, previous_state: 'submitted',
                               comment: 'Send Back test')
    claim.current_version = 2
    Event::NewVersion.build(submission: claim)
    claim.state = 'granted'
    Event::Decision.build(submission: claim, current_user: caseworker, previous_state: 'sent_back',
                          comment: 'Decision test')
    Event::Unassignment.build(submission: claim, user: caseworker, current_user: supervisor,
                              comment: 'unassignment 2')

    visit nsm_claim_history_path(claim)

    doc = Nokogiri::HTML(page.html)
    history = doc.css(
      '.govuk-table__body .govuk-table__cell:nth-child(2),' \
      '.govuk-table__body .govuk-table__cell:nth-child(3) p'
    ).map(&:text)

    expect(history).to eq(
      # User, Title, comment
      [
        'case worker', 'Caseworker removed from claim by super visor', 'unassignment 2',
        'case worker', 'Decision made to grant claim', 'Decision test',
        '', 'Received', 'Received from Provider with further information',
        'case worker', 'Sent back', 'Sent back to Provider for further information',
        'case worker', 'Caseworker note', 'User test note',
        'case worker', 'Claim risk changed to low risk', 'Risk change test',
        'case worker', 'Self-assigned by case worker', 'Manual assignment note',
        'case worker', 'Caseworker removed self from claim', 'unassignment 1',
        'case worker', 'Claim allocated to caseworker', '',
        '', 'Received', ''
      ]
    )
  end

  context 'when I am assigned to the claim' do
    before { create(:assignment, submission: claim, user: caseworker) }

    it 'lets me add a note' do
      travel_to fixed_arbitrary_date
      visit nsm_claim_history_path(claim)
      fill_in 'Add a note to the claim history (optional)', with: 'Here is a note'
      click_on 'Add to claim history'
      expect(page).to have_content "01 Feb 202309:00amcase worker\nCaseworker note\nHere is a note"
    end

    it 'rejects blank content' do
      visit nsm_claim_history_path(claim)
      click_on 'Add to claim history'
      expect(page).to have_content 'You cannot add an empty note to the claim history'
    end
  end
end
