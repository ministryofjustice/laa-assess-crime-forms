# spec/controllers/payments/steps/check_your_answers_controller_spec.rb
require 'rails_helper'

RSpec.describe Payments::Steps::CheckYourAnswersController, type: :controller do
  let(:submission_id) { SecureRandom.uuid }
  let(:request_type) { 'non_standard_magistrate' }
  let(:current_answers) { { 'id' => submission_id } }
  let(:fake_session) { instance_double(Decisions::MultiStepFormSession) }
  let(:form_object) { instance_double(Payments::Steps::CheckYourAnswersForm) }
  let(:report) { instance_double(Payments::CheckYourAnswers::Report) }
  let(:answers) { current_answers }

  before do
    allow(fake_session).to receive(:[]).with('request_type').and_return(request_type)
    allow(fake_session).to receive(:answers).and_return(current_answers)
    allow(fake_session).to receive(:answers=) { |new_answers| current_answers.replace(new_answers) }

    allow(controller).to receive_messages(multi_step_form_session: fake_session, current_multi_step_form_session: fake_session)
    allow(Payments::Steps::CheckYourAnswersForm).to receive(:build).and_return(form_object)
    allow(Payments::CheckYourAnswers::Report).to receive(:new).and_return(report)
  end

  {
    'non_standard_magistrate' => Payments::CostsSummary,
    'non_standard_mag_supplemental' => Payments::CostsSummaryAmendedAndClaimed,
    'non_standard_mag_amendment' => Payments::CostsSummaryAmended,
    'non_standard_mag_appeal' => Payments::CostsSummaryAmended
  }.each do |type, klass|
    context "when request_type is '#{type}'" do
      let(:request_type) { type }

      it "initializes #{klass} with answers" do
        expect(klass).to receive(:new).with(answers)
        get :edit, params: { id: submission_id }
      end
    end
  end

  describe 'submission-backed flows' do
    let(:refreshed_answers) { { 'id' => submission_id, 'claimed_total' => '25' } }

    it 'applies the persisted idempotency token and saves the refreshed answers to the multi step session' do
      persisted_token = SecureRandom.uuid
      session[:payments_last_submission] = { 'id' => submission_id, 'idempotency_token' => persisted_token }
      allow(controller).to receive(:refresh_answers_from_claim).and_return(refreshed_answers.dup)
      allow(controller).to receive(:clear_stale_submission_session)

      get :edit, params: { id: submission_id, submission: true }

      expect(current_answers).to include('claimed_total' => '25', 'idempotency_token' => persisted_token)
    end

    it 'redirects to your claims when the user returns after a successful submission' do
      session[:payments_last_submission] = { 'id' => submission_id, 'idempotency_token' => SecureRandom.uuid }
      expect(controller).not_to receive(:refresh_answers_from_claim)

      get :edit, params: { id: submission_id, submission: true }

      expect(response).to redirect_to(your_nsm_claims_path)
    end

    it 'removes stale payments session data for a different submission id' do
      stale_id = SecureRandom.uuid
      session[:payments_last_submission] = { 'id' => stale_id, 'idempotency_token' => SecureRandom.uuid }
      session["payments:#{stale_id}"] = { 'foo' => 'bar' }
      allow(controller).to receive(:refresh_answers_from_claim).and_return(refreshed_answers.dup)

      get :edit, params: { id: submission_id, submission: true }

      expect(session["payments:#{stale_id}"]).to be_nil
      expect(current_answers).to include('claimed_total' => '25')
    end

    it 'proceeds with new submission when previous submission id is blank' do
      session[:payments_last_submission] = { 'id' => nil, 'idempotency_token' => SecureRandom.uuid }
      allow(controller).to receive(:refresh_answers_from_claim).and_return(refreshed_answers.dup)

      get :edit, params: { id: submission_id, submission: true }

      expect(session.keys.grep(/\Apayments:/)).to be_empty
      expect(response).to be_successful
    end
  end
end
