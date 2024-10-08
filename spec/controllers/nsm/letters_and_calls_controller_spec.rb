require 'rails_helper'

RSpec.describe Nsm::LettersAndCallsController do
  describe '#index' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:letters_and_calls) { instance_double(Nsm::V1::LettersAndCallsSummary) }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive(:build).with(:letters_and_calls_summary, claim).and_return(letters_and_calls)
      allow(BaseViewModel).to receive(:build).with(:claim_summary, claim).and_return([])
      allow(BaseViewModel).to receive(:build).with(:core_cost_summary, claim).and_return([])
      allow(BaseViewModel).to receive(:build).with(:work_item, claim, 'work_items').and_return([])
    end

    it 'find and builds the required object' do
      get :index, params: { claim_id: }

      expect(Claim).to have_received(:find).with(claim_id)
      expect(BaseViewModel).to have_received(:build).with(:letters_and_calls_summary, claim)
      expect(BaseViewModel).to have_received(:build).with(:core_cost_summary, claim)
      expect(BaseViewModel).to have_received(:build).with(:claim_summary, claim)
      expect(BaseViewModel).to have_received(:build).with(:work_item, claim, 'work_items')
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render).and_call_original
      get :index, params: { claim_id: }

      expect(controller).to have_received(:render)
      expect(response).to be_successful
    end
  end

  context 'edit' do
    let(:claim) { instance_double(Claim, id: claim_id, risk: 'high') }
    let(:claim_id) { SecureRandom.uuid }
    let(:form) { instance_double(Nsm::LettersCallsForm) }
    let(:letters_and_calls) { [calls, letters] }
    let(:calls) do
      instance_double(Nsm::V1::LetterAndCall, type: double(value: 'calls'),
form_attributes: {})
    end
    let(:letters) do
      instance_double(Nsm::V1::LetterAndCall, type: double(value: 'letters'),
     form_attributes: {})
    end

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive(:build).and_return(letters_and_calls)
      allow(Nsm::LettersCallsForm).to receive(:new).and_return(form)
    end

    context 'when type is unknown' do
      it 'raises an error' do
        expect do
          get :edit, params: { claim_id: claim_id, id: 'other' }
        end.to raise_error(/No route matches/)
      end
    end

    context 'when URL is for letters' do
      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        get :edit, params: { claim_id: claim_id, id: 'letters' }

        expect(controller).to have_received(:render)
                          .with(locals: { claim: claim, form: form, item: letters })
        expect(response).to be_successful
      end
    end

    context 'when URL is for calls' do
      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        get :edit, params: { claim_id: claim_id, id: 'calls' }

        expect(controller).to have_received(:render)
                          .with(locals: { claim: claim, form: form, item: calls })
        expect(response).to be_successful
      end
    end
  end

  context 'show' do
    let(:claim) { instance_double(Claim, id: claim_id, risk: 'high') }
    let(:claim_id) { SecureRandom.uuid }
    let(:letters_and_calls) { [calls, letters] }
    let(:calls) do
      instance_double(Nsm::V1::LetterAndCall, type: double(value: 'calls'),
form_attributes: {})
    end
    let(:letters) do
      instance_double(Nsm::V1::LetterAndCall, type: double(value: 'letters'),
     form_attributes: {})
    end

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive(:build).and_return(letters_and_calls)
    end

    context 'when type is unknown' do
      it 'raises an error' do
        expect do
          get :show, params: { claim_id: claim_id, id: 'other' }
        end.to raise_error(/No route matches/)
      end
    end

    context 'when URL is for letters' do
      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        get :show, params: { claim_id: claim_id, id: 'letters' }

        expect(controller).to have_received(:render)
                          .with(locals: { claim: claim, item: letters })
        expect(response).to be_successful
      end
    end

    context 'when URL is for calls' do
      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        get :show, params: { claim_id: claim_id, id: 'calls' }

        expect(controller).to have_received(:render)
                          .with(locals: { claim: claim, item: calls })
        expect(response).to be_successful
      end
    end
  end

  context 'update' do
    let(:claim) { instance_double(Claim, id: claim_id, risk: 'high') }
    let(:claim_id) { SecureRandom.uuid }
    let(:form) { instance_double(Nsm::LettersCallsForm, save:) }
    let(:letters_and_calls) { [calls, letters] }
    let(:calls) do
      instance_double(Nsm::V1::LetterAndCall, type: double(value: 'calls'),
form_attributes: {})
    end
    let(:letters) do
      instance_double(Nsm::V1::LetterAndCall, type: double(value: 'letters'),
     form_attributes: {})
    end

    before do
      allow(BaseViewModel).to receive(:build).and_return(letters_and_calls)
      allow(Nsm::LettersCallsForm).to receive(:new).and_return(form)
      allow(Claim).to receive(:find).and_return(claim)
    end

    context 'for letters' do
      context 'when form save is successful' do
        let(:save) { true }

        it 'renders successfully with claims' do
          allow(controller).to receive(:render)
          put :update,
              params: { claim_id: claim_id, id: 'letters',
nsm_letters_calls_form_letters: { some: :data } }

          expect(controller).to redirect_to(
            nsm_claim_letters_and_calls_path(claim)
          )
          expect(response).to have_http_status(:found)
        end
      end

      context 'when form save is unsuccessful' do
        let(:save) { false }

        it 'renders successfully with claims' do
          allow(controller).to receive(:render)
          put :update,
              params: { claim_id: claim_id, id: 'letters',
nsm_letters_calls_form_letters: { some: :data } }

          expect(controller).to have_received(:render)
                            .with(:edit, locals: { claim: claim, form: form, item: letters })
          expect(response).to be_successful
        end
      end
    end

    context 'for calls' do
      context 'when form save is successful' do
        let(:save) { true }

        it 'renders successfully with claims' do
          allow(controller).to receive(:render)
          put :update,
              params: { claim_id: claim_id, id: 'calls',
nsm_letters_calls_form_calls: { some: :data } }

          expect(controller).to redirect_to(
            nsm_claim_letters_and_calls_path(claim)
          )
          expect(response).to have_http_status(:found)
        end
      end

      context 'when form save is unsuccessful' do
        let(:save) { false }

        it 'renders successfully with claims' do
          allow(controller).to receive(:render)
          put :update,
              params: { claim_id: claim_id, id: 'calls',
nsm_letters_calls_form_calls: { some: :data } }

          expect(controller).to have_received(:render)
                            .with(:edit, locals: { claim: claim, form: form, item: calls })
          expect(response).to be_successful
        end
      end
    end
  end
end
