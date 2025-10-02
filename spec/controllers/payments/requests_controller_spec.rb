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

  describe '#new' do
    it 'does not raise any errors' do
      expect { get :new }.not_to raise_error
    end
  end

  describe '#new existing form session' do
    before do
      get :new
    end

    let(:multi_step_form_id) { session[:multi_step_form_id] }

    it 'regenerates session[multi_step_form_id]' do
      expect { get :new }.to(change { session[:multi_step_form_id] })
    end

    it 'regenerates session["payments:#{multi_step_form_id}"]' do
      expect { get :new }.to(change { session["payments:#{multi_step_form_id}"] })
    end
  end
end
