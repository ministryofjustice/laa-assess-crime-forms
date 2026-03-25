require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'GET #failure' do
    it 'recalls forbidden error via warden' do
      expect { controller.failure }
        .to throw_symbol(:warden, hash_including(recall: 'Errors#forbidden', message: :forbidden))
    end
  end

  describe 'GET #passthru' do
    it 'redirects to the sign in page' do
      get :passthru

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
