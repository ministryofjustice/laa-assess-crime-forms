require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  let(:user) { create(:caseworker) }
  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      provider: 'azure_ad',
      uid: user.authentication_identity_for('azure_ad').subject,
      info: { email: user.email, first_name: user.first_name, last_name: user.last_name }
    )
  end

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
    request.env['omniauth.auth'] = auth_hash
    allow(Auth::UserAuthenticator).to receive(:call).with(auth_hash)
                                                    .and_return(Auth::Result.new(user: user, failure_reason: nil))
  end

  it 'binds a successful authentication session to the callback provider' do
    get :azure_ad

    expect(session[Auth::SessionContext::SESSION_KEY]).to eq('azure_ad')
    expect(response).to redirect_to(root_path)
  end
end
