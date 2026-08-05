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

  context 'with an authenticated session from a different provider' do
    before do
      session[Auth::SessionContext::SESSION_KEY] = 'azure_ad'
      allow(Auth::Provider).to receive(:current).and_return(Auth::Provider.fetch('silas'))
      allow(controller).to receive_messages(user_signed_in?: true, current_user: auth_user)
      allow(controller).to receive(:sign_out)
    end

    it 'clears the provider binding and requires a fresh sign-in' do
      get :index

      expect(controller).to have_received(:sign_out).with(auth_user)
      expect(session[Auth::SessionContext::SESSION_KEY]).to be_nil
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq(I18n.t('errors.auth_provider_changed'))
    end
  end
end
