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
    let(:flow_id) { '11111111-1111-4111-8111-111111111111' }
    let(:payment_request_id) { '22222222-2222-4222-8222-222222222222' }
    let(:session_answers) { { 'id' => flow_id, 'some' => 'answer', 'nested' => { 'a' => 1 } } }
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
      let(:ok_response) do
        {
          'payment_request_id' => payment_request_id,
          'payment_request' => {
            'id' => payment_request_id,
            'request_type' => 'non_standard_magistrate',
            'allowed_total' => 123.45,
            'ignored' => 'x'
          },
          'claim' => { 'laa_reference' => 'LAA-REF-123', 'ignored' => 'y' },
          'ignored' => 'z'
        }
      end
      let(:summary_double) { instance_double(Payments::ConfirmationSummary) }

      it 'redirects to confirmation with flow id and payment request id' do
        expected_payload = session_answers.merge('submitter_id' => controller.current_user.id)
        expect(client_double)
          .to receive(:create_payment_request)
          .with(expected_payload)
          .and_return(ok_response)

        post :create

        expect(response).to redirect_to(payments_confirmation_path(flow_id:, payment_request_id:))
        expect(session[:payments_confirmation_response]).to eq(
          {
            'payment_request' => { 'request_type' => 'non_standard_magistrate', 'allowed_total' => 123.45 },
            'claim' => { 'laa_reference' => 'LAA-REF-123' }
          }
        )
      end
    end
  end

  describe 'GET #confirmation' do
    let(:flow_id) { '11111111-1111-4111-8111-111111111111' }
    let(:payment_request_id) { '22222222-2222-4222-8222-222222222222' }
    let(:ok_response) do
      {
        'payment_request' => { 'request_type' => 'non_standard_magistrate', 'allowed_total' => 123.45 },
        'claim' => { 'laa_reference' => 'LAA-REF-123' }
      }
    end
    let(:summary_double) { instance_double(Payments::ConfirmationSummary) }

    it 'builds a confirmation summary from session response' do
      allow(Payments::ConfirmationSummary)
        .to receive(:new)
        .with(ok_response)
        .and_return(summary_double)

      get :confirmation,
          params: { flow_id:, payment_request_id: },
          session: { payments_confirmation_response: ok_response }

      expect(assigns(:payment_confirmation)).to eq(summary_double)
      expect(session[:payments_confirmation_response]).to be_nil
    end
  end

  describe '#new existing form session' do
    let(:multi_step_form_id) { session[:multi_step_form_id] }

    before do
      get :new
    end

    it 'regenerates form id at top level' do
      expect { get :new }.to(change { session[:multi_step_form_id] })
    end

    it 'regenerates payments keys' do
      expect { get :new }.to(change { session["payments:#{multi_step_form_id}"] })
    end
  end
end
