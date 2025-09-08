require 'rails_helper'

RSpec.describe 'Payment Requests', :stub_oauth_token do
  let(:supervisor) { create(:supervisor, first_name: 'Ad', last_name: 'Minh', email: 'ad@minh.com') }

  describe 'when given a list of results' do
    let(:results) do
      [{
        submitted_at: (DateTime.now - 1).to_s,
          request_type: :assigned_counsel,
          payment_request_claim: {
            laa_reference: 'LAA-AAAAAA',
            client_last_name: 'Joe Client',
            firm_name: 'A Firm'
          }
      }, {
        submitted_at: (DateTime.now - 1).to_s,
          request_type: :assigned_counsel,
          payment_request_claim: {
            laa_reference: 'LAA-BBBBBB',
            client_last_name: 'Joe Client',
            firm_name: 'B Firm'
          }
      }]
    end

    before do
      allow_any_instance_of(Payments::SearchResults).to receive(:conduct_search).and_return(
        {
          metadata: { total_results: results.count }, data: results
        }
      )
      sign_in supervisor
      visit payments_requests_path
    end

    it 'renders the page' do
      expect(page).to have_content('Payment Requests')
    end

    it 'allows sorting in both directions' do
      within 'table' do
        expect(page).to have_content(/A Firm.*B Firm/)
      end

      allow_any_instance_of(Payments::SearchResults).to receive(:conduct_search).and_return(
        {
          metadata: { total_results: results.count },
          data: results.reverse
        }
      )

      click_on 'Firm name'

      within 'table' do
        expect(page).to have_content(/B Firm.*A Firm/)
      end
    end
  end
end
