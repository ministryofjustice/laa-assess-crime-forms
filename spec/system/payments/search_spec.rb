require 'rails_helper'

RSpec.describe 'Search', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'John', last_name: 'Everyman') }
  let(:endpoint) { 'https://appstore.example.com/v1/payment_requests/searches' }
  let(:payload) do
    {
      page: 1,
      per_page: 20,
      query: 'QUERY',
      sort_by: 'submitted_at',
      sort_direction: 'descending',
    }
  end

  let(:your_applications_payload) do
    {
      page: 1,
      per_page: 20,
      sort_by: 'submitted_at',
      sort_direction: 'descending',
    }
  end

  let(:your_applications_stub) do
    stub_request(:post, endpoint).with(body: your_applications_payload).to_return(
      status: 201,
      body: { metadata: { total_results: 0 },
        data: [],
        raw_data: [] }.to_json
    )
  end

  before do
    your_applications_stub
    sign_in caseworker
  end

  it 'displays as expected' do
    visit new_payments_search_path
    click_button 'Search'

    expect(page)
      .to have_title('Search for a payment')
      .and have_content('Enter details in at least one field to search for a payment request')
  end

  context 'when I search for an application that has already been imported' do
    let(:payment_request_claim) { { laa_reference: 'LAA-0111', client_last_name: 'Dickens' } }

    let(:data) do
      [
        id: SecureRandom.uuid,
        request_type: 'non_standard_mag',
        submitted_at: Time.zone.now.to_s,
        payment_request_claim: payment_request_claim
      ]
    end

    let(:stub) do
      stub_request(:post, endpoint).with(body: payload).to_return(
        status: 201,
        body: { metadata: { total_results: 1 },
          data: data }.to_json
      )
    end

    before do
      stub
    end

    it 'lets me search and shows me a result' do
      visit new_payments_search_path
      click_button 'Search'
      fill_in 'Enter a defendant, firm account, UFN or LAA reference', with: 'QUERY'
      within 'main' do
        click_button 'Search'
      end

      expect(stub).to have_been_requested
    end
  end

  context 'when I search with invalid search criteria' do
    it 'displays an error when no filters applied' do
      visit new_payments_search_path
      click_button 'Search'
      within('main') { click_on 'Search' }
      expect(page).to have_content('Enter details in at least one field to search for a payment request')
    end

    it 'displays an error when unparsable date strings used as filters' do
      visit new_payments_search_path
      fill_in 'Submission date from', with: '31/4/2023'
      fill_in 'Submission date to', with: '31/13/2024'
      fill_in 'Received from', with: 'adaddddd'
      fill_in 'Received to', with: '2024367' # the 367th day of 2024 (a leap year)

      within('main') { click_on 'Search' }

      expect(page)
        .to have_content('Enter a valid submission date from')
        .and have_content('Enter a valid submission date to')
        .and have_content('Enter a valid received from')
        .and have_content('Enter a valid received to')
    end
  end

  context 'when I search for something with no matches' do
    before do
      stub_request(:post, endpoint).to_return(
        status: 201,
        body: { metadata: { total_results: 0 }, data: [] }.to_json
      )
    end

    it 'tells me if there are no results' do
      visit new_payments_search_path
      fill_in 'Enter a defendant, firm account, UFN or LAA reference', with: 'query'
      within('main') { click_on 'Search' }
      expect(page).to have_content 'There are no results that match the search criteria'
    end
  end

  context 'when the app store has an error' do
    before do
      stub_request(:post, endpoint).to_return(
        status: 502
      )
    end

    it 'notifies sentry and shows an error' do
      expect(Sentry).to receive(:capture_exception)
      visit new_payments_search_path
      within('main') { click_on 'Search' }
      expect(page).to have_content 'Something went wrong trying to perform this search'
    end
  end

  context 'when searching with filters' do
    let(:payload) do
      {
        page: 1,
        per_page: 20,
        sort_by: 'submitted_at',
        sort_direction: 'descending',
        submitted_from: '20/4/2023',
        submitted_to: '21/4/2023',
        received_from: '22/4/2023',
        received_to: '23/4/2023'
      }
    end
    let(:stub) do
      stub_request(:post, endpoint).with(body: payload).to_return(
        status: 201,
        body: { metadata: { total_results: 0 }, data: [] }.to_json
      )
    end

    before { stub }

    it 'lets me search and shows me a result' do
      visit new_payments_search_path

      fill_in 'Submission date from', with: '20/4/2023'
      fill_in 'Submission date to', with: '21/4/2023'
      fill_in 'Received from', with: '22/4/2023'
      fill_in 'Received to', with: '23/4/2023'
      within('main') { click_button 'Search' }

      expect(stub).to have_been_requested
    end
  end
end
