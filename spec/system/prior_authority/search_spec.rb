require 'rails_helper'

RSpec.describe 'Search', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'John', last_name: 'Everyman') }
  let(:endpoint) { 'https://appstore.example.com/v1/submissions/searches' }
  let(:payload) do
    {
      application_type: 'crm4',
      page: 1,
      per_page: 20,
      query: 'QUERY',
      sort_by: 'last_updated',
      sort_direction: 'descending',
    }
  end

  let(:your_applications_stub) do
    stub_request(:post, endpoint).with(body: your_applications_payload).to_return(
      status: 201,
      body: { metadata: { total_results: 0 },
              raw_data: [] }.to_json
    )
  end

  let(:your_applications_payload) do
    {
      page: 1,
      sort_by: 'last_updated',
      sort_direction: 'descending',
      per_page: 20,
      application_type: 'crm4',
      status_with_assignment: %w[in_progress provider_updated],
      current_caseworker_id: caseworker.id
    }
  end

  before do
    your_applications_stub
    sign_in caseworker
  end

  it 'displays as expected' do
    visit prior_authority_root_path
    click_on 'Search'

    expect(page)
      .to have_title('Search for an application')
      .and have_content('Enter details in at least one field to search for an application')
  end

  context 'when I search for an application that has already been imported' do
    let(:application) { build :prior_authority_application }
    let(:stub) do
      stub_request(:post, endpoint).with(body: payload).to_return(
        status: 201,
        body: { metadata: { total_results: 1 },
                raw_data: [{ application_id: application.id, application: application.data, application_type: 'crm4',
application_state: application.state, last_updated_at: 1.day.ago }] }.to_json
      )
    end

    before do
      stub
      application.assigned_user_id = caseworker.id
    end

    it 'lets me search and shows me a result' do
      stub_app_store_interactions(application)
      visit prior_authority_root_path
      click_on 'Search'
      fill_in 'Enter any combination', with: 'QUERY'
      within 'main' do
        click_on 'Search'
      end

      expect(stub).to have_been_requested

      click_on application.data['laa_reference']

      expect(page).to have_current_path prior_authority_application_path(application)
    end
  end

  context 'when I search with invalid search criteria' do
    it 'displays an error when no filters applied' do
      visit prior_authority_root_path
      click_on 'Search'
      within('main') { click_on 'Search' }
      expect(page).to have_content('Enter some application details or filter your search criteria')
    end

    it 'displays an error when unparsable date strings used as filters' do
      visit prior_authority_root_path
      click_on 'Search'
      fill_in 'Submission date from', with: '31/4/2023'
      fill_in 'Submission date to', with: '31/13/2024'
      fill_in 'Last updated from', with: 'adaddddd'
      fill_in 'Last updated to', with: '2024367' # the 367th day of 2024 (a leap year)

      within('main') { click_on 'Search' }

      expect(page)
        .to have_content('Enter a valid submission date from')
        .and have_content('Enter a valid submission date to')
        .and have_content('Enter a valid last updated from')
        .and have_content('Enter a valid last updated to')
    end
  end

  context 'when I search for something with no matches' do
    before do
      stub_request(:post, endpoint).with(body: payload).to_return(
        status: 201,
        body: { metadata: { total_results: 0 }, raw_data: [] }.to_json
      )
    end

    it 'tells me if there are no results' do
      visit prior_authority_search_path(prior_authority_search_form: { query: 'QUERY' })
      expect(page).to have_content 'There are no results that match the search criteria'
    end
  end

  context 'when the app store has an error' do
    before do
      stub_request(:post, endpoint).with(body: payload).to_return(
        status: 502
      )
    end

    it 'notifies sentry and shows an error' do
      expect(Sentry).to receive(:capture_exception)
      visit prior_authority_search_path(prior_authority_search_form: { query: 'QUERY' })
      expect(page).to have_content 'Something went wrong trying to perform this search'
    end
  end

  context 'when there are multiple results' do
    let(:applications) { build_list(:prior_authority_application, 20) }
    let(:payloads) do
      [
        { application_type: 'crm4', page: 1, per_page: 20, query: 'QUERY',
          sort_by: 'last_updated', sort_direction: 'descending' },
        { application_type: 'crm4', page: 1, per_page: 20, query: 'QUERY',
          sort_by: 'laa_reference', sort_direction: 'ascending' },
        { application_type: 'crm4', page: 2, per_page: 20, query: 'QUERY',
          sort_by: 'laa_reference', sort_direction: 'ascending' },
      ]
    end

    let(:stubs) do
      payloads.map do |payload|
        stub_request(:post, endpoint).with(body: payload).to_return(
          status: 201, body: { metadata: { total_results: 21 },
                               raw_data: applications.map do |app|
                                 { application_id: app.id, application: app.data, application_type: 'crm4',
                                   application_state: app.state, last_updated_at: 1.day.ago }
                               end }.to_json
        )
      end
    end

    before { stubs }

    it 'lets me sort and paginate' do
      visit prior_authority_search_path(prior_authority_search_form: { query: 'QUERY' })
      within('.govuk-table__head') { click_link 'LAA reference' }
      within('.govuk-pagination__list') { click_on '2' }
      expect(stubs).to all have_been_requested
    end
  end

  context 'when searching with filters' do
    let(:payload) do
      {
        application_type: 'crm4',
        caseworker_id: caseworker.id,
        page: 1,
        per_page: 20,
        sort_by: 'last_updated',
        sort_direction: 'descending',
        status_with_assignment: 'rejected',
        submitted_from: '20/4/2023',
        submitted_to: '21/4/2023',
        updated_from: '22/4/2023',
        updated_to: '23/4/2023'
      }
    end
    let(:stub) do
      stub_request(:post, endpoint).with(body: payload).to_return(
        status: 201,
        body: { metadata: { total_results: 0 }, raw_data: [] }.to_json
      )
    end

    before { stub }

    it 'lets me search and shows me a result' do
      visit prior_authority_root_path
      click_on 'Search'

      fill_in 'Submission date from', with: '20/4/2023'
      fill_in 'Submission date to', with: '21/4/2023'
      fill_in 'Last updated from', with: '22/4/2023'
      fill_in 'Last updated to', with: '23/4/2023'
      select caseworker.display_name, from: 'Caseworker'
      select 'Rejected', from: 'Status'
      within('main') { click_on 'Search' }

      expect(stub).to have_been_requested
    end
  end
end
