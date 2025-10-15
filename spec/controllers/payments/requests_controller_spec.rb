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

  describe 'POST #create' do
    let(:session_answers) { { 'some' => 'answer', 'nested' => { 'a' => 1 } } }
    let(:session_double) { instance_double(Decisions::MultiStepFormSession, id: 'session-123', answers: session_answers) }
    let(:client_double) { instance_double(AppStoreClient) }

    before do
      allow(controller).to receive(:current_multi_step_form_session).and_return(session_double)
      allow(AppStoreClient).to receive(:new).and_return(client_double)
    end

    context 'when the AppStore returns errors' do
      it 'raises a RuntimeError' do
        expected_payload = session_answers.merge('submitter_id' => controller.current_user.id)
        expect(client_double)
          .to receive(:create_payment_request)
          .with(expected_payload)
          .and_raise(RuntimeError)

        expect { post :create }.to raise_error(RuntimeError)
      end
    end

    context 'when the AppStore succeeds' do
      let(:ok_response) { { 'payment_request_id' => 'pr-123' } }
      let(:summary_double) { instance_double(Payments::ConfirmationSummary) }

      it 'builds a confirmation summary and renders :confirmation' do
        expected_payload = session_answers.merge('submitter_id' => controller.current_user.id)
        expect(client_double)
          .to receive(:create_payment_request)
          .with(expected_payload)
          .and_return(ok_response)

        allow(Payments::ConfirmationSummary)
          .to receive(:new)
          .with(ok_response)
          .and_return(summary_double)

        post :create

        expect(assigns(:payment_confirmation)).to eq(summary_double)
        expect(response).to render_template(:confirmation)
      end
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
