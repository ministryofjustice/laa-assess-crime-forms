require 'rails_helper'

RSpec.describe 'Work items' do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:claim) }

  before do
    sign_in user
    create(:assignment, submission: claim, user: user)
    visit '/'
    click_on 'Accept analytics cookies'
  end

  it 'can adjust a work item record' do
    visit nsm_claim_work_items_path(claim)

    within('.govuk-table__row', text: 'Waiting') do
      expect(page).to have_content(
        'Waiting' \
        '2 hours41 minutes' \
        '95%' \
        '£125.58' \
        'Change'
      )
      click_on 'Change'
    end

    choose 'Yes, remove uplift'
    fill_in 'Hours', with: '10'
    fill_in 'Minutes', with: '59'
    fill_in 'Explain your decision', with: 'Testing'

    click_on 'Save changes'

    # need to access page directly as not JS enabled
    visit nsm_claim_work_items_path(claim)

    within('.govuk-table__row', text: 'Waiting') do
      expect(page).to have_content(
        'Waiting' \
        '2 hours41 minutes' \
        '95%' \
        '£125.58' \
        '10 hours59 minutes' \
        '0%' \
        '£263.60' \
        'Change'
      )
    end
  end

  it 'can remove all uplift' do
    visit nsm_claim_work_items_path(claim)

    click_on 'Remove uplifts for all items'

    fill_in 'Explain your decision', with: 'Testing'

    click_on 'Yes, remove all uplift'

    # need to access page directly as not JS enabled
    visit nsm_claim_work_items_path(claim)

    within('.govuk-table__row', text: 'Waiting') do
      expect(page).to have_content(
        'Waiting' \
        '2 hours41 minutes' \
        '95%' \
        '£125.58' \
        '2 hours41 minutes' \
        '0%' \
        '£64.40' \
        'Change'
      )
    end

    expect(page).to have_no_content('Remove uplifts for all items')
  end

  context 'when claim has been assessed' do
    let(:claim) { create(:claim, state: 'granted') }

    it 'lets me view details instead of changing them' do
      visit nsm_claim_work_items_path(claim)
      within('main') { expect(page).to have_no_content 'Change' }
      click_on 'View'
      expect(page).to have_content(
        'Waiting' \
        'Date12 December 2022' \
        'Time spent2 hours 41 minutes' \
        'Fee earner initialsaaa' \
        'Uplift claimed95%' \
        'Claim cost£125.58'
      )
    end
  end
end
