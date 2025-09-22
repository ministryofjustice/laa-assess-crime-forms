require 'rails_helper'

RSpec.describe Payments::ClaimReferencesController, type: :controller do
  describe 'edit' do
    context 'when user has nsm access only' do
      let(:user) { create(:caseworker, roles: [build(:role, :caseworker, service: :nsm)]) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'does not redirect to home page with error' do
        get :edit
        expect(controller).not_to redirect_to(root_path)
      end
    end

    context 'when user is has viewer access only' do
      let(:user) { create(:viewer) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'redirects to homepage with error' do
        get :edit
        expect(controller).to redirect_to(root_path)
        expect(flash.now[:alert]).to match(/You are not authorised to perform this action/)
      end
    end
  end
end
