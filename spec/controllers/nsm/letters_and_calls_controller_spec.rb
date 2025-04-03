require 'rails_helper'

RSpec.describe Nsm::LettersAndCallsController do
  let(:claim) do
    build :claim, assigned_user_id: user.id, data: { disbursements: [], work_items: [], letters_and_calls: [letters, calls] }
  end
  let(:user) { create :caseworker }
  let(:letters) { { type: 'letters' } }
  let(:calls) { { type: 'calls' } }

  before do
    allow(Claim).to receive(:load_from_app_store).and_return(claim)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'index' do
    it 'renders successfully' do
      get :index, params: { claim_id: claim.id }
      expect(response).to be_successful
    end
  end

  describe 'adjusted' do
    it 'renders successfully' do
      get :adjusted, params: { claim_id: claim.id }
      expect(response).to be_successful
    end
  end

  describe 'show' do
    it 'renders successfully' do
      get :show, params: { claim_id: claim.id, id: 'letters' }
      expect(response).to be_successful
    end
  end

  describe 'edit' do
    it 'renders successfully' do
      get :edit, params: { claim_id: claim.id, id: 'letters' }
      expect(response).to be_successful
    end
  end

  describe 'update' do
    let(:form) { instance_double(Nsm::LettersCallsForm::Letters, save!: save) }

    before do
      allow(Nsm::LettersCallsForm::Letters).to receive(:new).and_return(form)
      put :update,
          params: { claim_id: claim.id, id: 'letters',
                    nsm_letters_calls_form_letters: { uplift: 0, count: 0, explanation: 'Something' } }
    end

    context 'when form save is successful' do
      let(:save) { true }

      it 'redirects' do
        expect(controller).to redirect_to(
          nsm_claim_letters_and_calls_path(claim)
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
