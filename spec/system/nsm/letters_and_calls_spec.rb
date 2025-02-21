require 'rails_helper'

RSpec.describe 'Letters and Calls', :stub_oauth_token, type: :system do
  include ActionView::Helpers::TranslationHelper

  let(:user) { create(:caseworker) }
  let(:claim) { build(:claim) }

  before do
    stub_app_store_interactions(claim)
    sign_in user
    claim.assigned_user_id = user.id
    visit '/'
    click_on 'Accept analytics cookies'
  end

  it 'can adjust a letter record' do
    visit nsm_claim_letters_and_calls_path(claim)

    within('.govuk-table__row', text: 'Letters') do
      expect(page).to have_content(
        'Letters' \
        '12' \
        '95%' \
        '£95.71'
      )
      click_on 'Letters'
    end

    choose 'Yes, remove uplift'
    fill_in 'Change number of letters', with: '22'
    fill_in 'Explain your decision', with: 'Testing'

    click_on 'Save changes'

    within('.govuk-table__row', text: 'Letters') do
      expect(page).to have_content(
        'Letters' \
        '12' \
        '95%' \
        '£95.71' \
        '£89.98'
      )
    end

    visit adjusted_nsm_claim_letters_and_calls_path(claim)

    within('.govuk-table__row', text: 'Letters') do
      expect(page).to have_content(
        'Letters' \
        'Testing' \
        '22' \
        '0%' \
        '£89.98'
      )
    end
  end

  it 'can adjust a call record' do
    visit nsm_claim_letters_and_calls_path(claim)

    within('.govuk-table__row', text: 'Calls') do
      expect(page).to have_content(
        'Calls' \
        '4' \
        '20%' \
        '£19.63'
      )
      click_on 'Calls'
    end

    choose 'Yes, remove uplift'
    fill_in 'Change number of calls', with: '22'
    fill_in 'Explain your decision', with: 'Testing'

    click_on 'Save changes'

    within('.govuk-table__row', text: 'Calls') do
      expect(page).to have_content(
        'Calls' \
        '4' \
        '20%' \
        '£19.63' \
        '£89.98'
      )
    end
  end

  it 'can remove all uplift' do
    visit nsm_claim_letters_and_calls_path(claim)

    click_on 'Remove uplifts for all items'

    fill_in 'Explain your decision', with: 'Testing'

    click_on 'Yes, remove all uplift'

    within('.govuk-table__row', text: 'Letters') do
      expect(page).to have_content(
        'Letters' \
        '12' \
        '95%' \
        '£95.71' \
        '£49.08'
      )
    end

    within('.govuk-table__row', text: 'Calls') do
      expect(page).to have_content(
        'Calls' \
        '4' \
        '20%' \
        '£19.63' \
        '£16.36'
      )
    end

    expect(page).to have_no_content('Remove uplifts for all items')
  end

  context 'when claim has been assessed' do
    let(:claim) { build(:claim, state: 'granted') }

    it 'lets me view details instead of changing them' do
      visit nsm_claim_letters_and_calls_path(claim)
      click_on 'Letters'

      expect(page).to have_content("#{t('nsm.letters_and_calls.show.number', type: 'letters')}12")
        .and have_content("#{t('nsm.letters_and_calls.show.rate')}£4.09")
        .and have_content("#{t('nsm.letters_and_calls.show.uplift_requested')}95%")
        .and have_content("#{t('nsm.letters_and_calls.show.total_claimed')}£95.71")
    end
  end
end
