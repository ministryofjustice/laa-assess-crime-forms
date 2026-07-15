require 'rails_helper'
require 'request_store'

RSpec.describe ApplicationController, type: :controller do
  controller do
    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    def index
      render plain: OutboundRequestId.current
    end
  end

  before do
    routes.draw { get 'index' => 'anonymous#index' }
    allow_any_instance_of(ActionDispatch::Request).to receive(:request_id)
      .and_return('A8B0EB88-EA9A-DCAB-8902-CD521F2D5F51')
  end

  after { RequestStore.clear! }

  it 'stores the Rails request id for downstream service calls' do
    get :index

    expect(response.body).to eq('nscc-assess-a8b0eb88ea9adcab8902cd521f2d5f51')
  end
end
