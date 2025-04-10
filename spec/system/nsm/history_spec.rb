require 'rails_helper'

RSpec.describe 'History events', :stub_oauth_token do
  let(:caseworker) { create(:caseworker) }
  let(:claim) { build(:claim) }
  let(:fixed_arbitrary_date) { Time.zone.local(2023, 2, 1, 9, 0) }
  let(:supervisor) { create(:supervisor) }

  before do
    stub_app_store_interactions(claim)
    claim
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'
  end

  context 'paginated events' do
    before do
      now = DateTime.current

      travel_to(now - 10.hours)
      Event::NewVersion.build(submission: claim)

      travel_to(now - 9.hours)
      Event::Assignment.build(submission: claim, current_user: caseworker)

      travel_to(now - 8.hours)
      Event::Unassignment.build(submission: claim, user: caseworker, current_user: caseworker,
                                comment: 'unassignment 1')

      travel_to(now - 7.hours)
      Event::Assignment.build(submission: claim, current_user: caseworker, comment: 'Manual assignment note')

      travel_to(now - 6.hours)
      Event::ChangeRisk.build(submission: claim, explanation: 'Risk change test', previous_risk_level: 'high',
                              current_user: caseworker)

      travel_to(now - 5.hours)
      Event::Note.build(submission: claim, current_user: caseworker, note: 'User test note')
      claim.state = 'sent_back'
      travel_to(now - 4.hours)
      Nsm::Event::SendBack.build(submission: claim, current_user: caseworker, previous_state: 'submitted',
                                 comment: 'Send Back test')
      claim.current_version = 2
      travel_to(now - 3.hours)
      Event::NewVersion.build(submission: claim)
      claim.state = 'granted'
      travel_to(now - 2.hours)
      Event::Decision.build(submission: claim, current_user: caseworker, previous_state: 'sent_back',
                            comment: 'Decision test')
      travel_to(now - 1.hour)
      Event::Unassignment.build(submission: claim, user: caseworker, current_user: supervisor,
                                comment: 'unassignment 2')
      travel_to(now - 50.minutes)
      Event::GdprDocumentsDeleted.build(submission: claim)

      travel_to(now)
    end

    it 'shows all (visible) events in the history page 1' do
      visit nsm_claim_history_path(claim)

      doc = Nokogiri::HTML(page.html)
      history = doc.css(
        '.govuk-table__body .govuk-table__cell:nth-child(2),' \
        '.govuk-table__body .govuk-table__cell:nth-child(3) p'
      ).map(&:text)

      expect(history).to eq(
        # User, Title, comment
        [
          '', 'Uploads deleted', 'Uploads are deleted after 6 months to keep provider data safe',
          caseworker.display_name, "Caseworker removed from claim by #{supervisor.display_name}", 'unassignment 2',
          caseworker.display_name, 'Decision made to grant claim', 'Decision test',
          '', 'Received', 'Received from Provider with further information',
          caseworker.display_name, 'Sent back', 'Sent back to Provider for further information',
          caseworker.display_name, 'Caseworker note', 'User test note',
          caseworker.display_name, 'Claim risk changed to low risk', 'Risk change test',
          caseworker.display_name, "Self-assigned by #{caseworker.display_name}", 'Manual assignment note',
          caseworker.display_name, 'Caseworker removed self from claim', 'unassignment 1',
          caseworker.display_name, 'Claim allocated to caseworker', ''
        ]
      )
    end

    it 'shows all (visible) events in the history page 2' do
      visit nsm_claim_history_path(claim)
      click_on 'Next'

      doc = Nokogiri::HTML(page.html)
      history = doc.css(
        '.govuk-table__body .govuk-table__cell:nth-child(2),' \
        '.govuk-table__body .govuk-table__cell:nth-child(3) p'
      ).map(&:text)

      expect(history).to eq(
        # User, Title, comment
        ['', 'Received', '']
      )
    end
  end

  context 'when I am assigned to the claim' do
    before { claim.assigned_user_id = caseworker.id }

    it 'lets me add a note' do
      travel_to(fixed_arbitrary_date)
      visit nsm_claim_history_path(claim)
      fill_in 'Add a note to the claim history (optional)', with: 'Here is a note'
      click_on 'Add to claim history'
      expect(page).to have_content "01 Feb 202309:00am#{caseworker.display_name}\nCaseworker note\nHere is a note"
    end

    it 'rejects blank content' do
      visit nsm_claim_history_path(claim)
      click_on 'Add to claim history'
      expect(page).to have_content 'You cannot add an empty note to the claim history'
    end
  end
end
