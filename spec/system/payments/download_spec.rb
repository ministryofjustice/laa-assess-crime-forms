require 'rails_helper'

RSpec.describe 'Payments download', :stub_oauth_token do
  let(:caseworker) { create(:caseworker) }

  before do
    allow(FeatureFlags).to receive_messages(payments: double(enabled?: true))
    sign_in caseworker
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'shows monthly download links for the current month and previous 11 months under each heading' do
    travel_to Time.zone.local(2026, 6, 15, 12) do
      visit payments_download_index_path
    end

    expect(page).to have_current_path(payments_download_index_path)
    expect(page).to have_selector('h2', text: 'CRM7')
    expect(page).to have_selector('h2', text: 'CRM8')
    expect(page).to have_selector(:xpath, "//h2[normalize-space()='CRM7']/following-sibling::ul[1]/li/a", count: 12)
    expect(page).to have_selector(:xpath, "//h2[normalize-space()='CRM8']/following-sibling::ul[1]/li/a", count: 12)

    crm7_first_link = find(:xpath, "//h2[normalize-space()='CRM7']/following-sibling::ul[1]/li[1]/a")
    crm7_first_link_params = Rack::Utils.parse_nested_query(URI.parse(crm7_first_link[:href]).query)
    expect(crm7_first_link_params).to include(
      'created_at_from' => '2026-06-01',
      'created_at_to' => '2026-06-30'
    )
    expect(crm7_first_link_params.fetch('request_type')).to eq(
      %w[non_standard_magistrate
         non_standard_mag_appeal
         non_standard_mag_amendment
         non_standard_mag_supplemental
         breach_of_injunction]
    )

    crm8_first_link = find(:xpath, "//h2[normalize-space()='CRM8']/following-sibling::ul[1]/li[1]/a")
    crm8_first_link_params = Rack::Utils.parse_nested_query(URI.parse(crm8_first_link[:href]).query)
    expect(crm8_first_link_params).to include(
      'created_at_from' => '2026-06-01',
      'created_at_to' => '2026-06-30'
    )
    expect(crm8_first_link_params.fetch('request_type')).to eq(
      %w[assigned_counsel
         assigned_counsel_appeal
         assigned_counsel_amendment
         assigned_counsel_supplemental]
    )
  end
  # rubocop:enable RSpec/MultipleExpectations
end
