require 'rails_helper'

RSpec.describe Nsm::ChangeRisksController, type: :controller do
  context 'edit' do
    let(:claim) { instance_double(Claim, id: claim_id, risk: 'high') }
    let(:claim_id) { SecureRandom.uuid }
    let(:risk) { instance_double(Nsm::ChangeRiskForm) }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(Nsm::ChangeRiskForm).to receive(:new).and_return(risk)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :edit, params: { claim_id: }

      expect(controller).to have_received(:render)
                        .with(locals: { claim:, risk: })
      expect(response).to be_successful
    end
  end

  context 'update' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:risk) { instance_double(Nsm::ChangeRiskForm, save:, risk_level:) }
    let(:user) { instance_double(User, access_logs:) }
    let(:access_logs) { double(AccessLog, create!: true) }
    let(:risk_level) { 'high' }
    let(:save) { true }

    before do
      allow(User).to receive(:first_or_create).and_return(user)
      allow(Nsm::ChangeRiskForm).to receive(:new).and_return(risk)
      allow(Claim).to receive(:find).and_return(claim)
    end

    it 'builds a risk object' do
      put :update, params: {
        claim_id: claim.id,
        nsm_change_risk_form: { risk_level: 'low', explanation: nil, id: claim.id }
      }

      expected_params = ActionController::Parameters.new(risk_level: 'low',
                                                         explanation: '',
                                                         id: claim.id,
                                                         current_user: user).permit!
      expect(Nsm::ChangeRiskForm).to have_received(:new).with(expected_params)
    end

    context 'when decision has an erorr being updated' do
      let(:save) { false }

      it 're-renders the edit page' do
        allow(controller).to receive(:render)
        put :update, params: {
          claim_id: claim.id,
          nsm_change_risk_form: { risk_level: 'low', explanation: nil, id: claim.id }
        }

        expect(controller).to have_received(:render)
                          .with(:edit, locals: { claim:, risk: })
      end
    end
  end
end
