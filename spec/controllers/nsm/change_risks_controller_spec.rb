require 'rails_helper'

RSpec.describe Nsm::ChangeRisksController, type: :controller do
  let(:claim) { build :claim, assigned_user_id: user.id }
  let(:user) { create :caseworker }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(Claim).to receive(:load_from_app_store).and_return(claim)
  end

  describe 'edit' do
    it 'renders successfully' do
      get :edit, params: { claim_id: claim.id }
      expect(response).to be_successful
    end
  end

  describe 'update' do
    let(:form) { instance_double(Nsm::ChangeRiskForm, save: save, risk_level: 'high') }

    before do
      allow(Nsm::ChangeRiskForm).to receive(:new).and_return(form)
      put :update,
          params: { claim_id: claim.id,
                    nsm_change_risk_form: { risk_level: 'high', explanation: 'Something' } }
    end

    context 'when form save is successful' do
      let(:save) { true }

      it 'redirects' do
        expect(controller).to redirect_to(
          nsm_claim_claim_details_path(claim)
        )
      end
    end

    context 'when form save is unsuccessful' do
      let(:save) { false }

      it 'renders rather than redirects' do
        expect(response).to be_successful
      end
    end
  end
end
