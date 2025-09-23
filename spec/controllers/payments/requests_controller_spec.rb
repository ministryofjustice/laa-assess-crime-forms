require 'rails_helper'

RSpec.describe Payments::RequestsController, :stub_oauth_token do
  before do
    stub_request(:post, 'https://appstore.example.com/v1/payment_requests/searches').to_return(
      status: 201,
      body: { metadata: { total_results: 0 }, data: [] }.to_json
    )
  end

  describe '#requests' do
    it 'does not raise any errors' do
      expect { get :index }.not_to raise_error
    end
  end
end
