require 'rails_helper'

RSpec.describe Payments::Steps::ClaimTypeForm, type: :model do
  subject(:form) { described_class.new(request_type:, multi_step_form_session:) }

  let(:rack_session_hash) { {} }
  let(:multi_step_form_session) do
    Decisions::MultiStepFormSession.new(
      process: 'payments',
      session: rack_session_hash,
      session_id: 'test-session'
    )
  end

  describe '#save' do
    context 'when claim_type is blank' do
      let(:request_type) { nil }

      it 'is invalid, returns false, and does not change answers' do
        before_answers = multi_step_form_session.answers.dup

        expect(form.save).to be(false)
        expect(form.errors[:request_type]).to be_present
        expect(multi_step_form_session.answers).to eq(before_answers)
      end
    end

    context 'when claim_type is invalid' do
      let(:request_type) { 'totally_invalid' }

      it 'is invalid, returns false, and does not change answers' do
        before_answers = multi_step_form_session.answers.dup

        expect(form.save).to be(false)
        expect(form.errors[:request_type]).to be_present
        expect(multi_step_form_session.answers).to eq(before_answers)
      end
    end

    context 'when claim_type is valid' do
      let(:request_type) { 'assigned_counsel' }

      context 'equals the value already in the session (unchanged)' do
        before do
          multi_step_form_session[:request_type] = 'assigned_counsel'
          multi_step_form_session[:some_other_answer] = 'keep-me'
        end

        it 'returns true, does not mutate answers' do
          before_answers = multi_step_form_session.answers.dup

          expect(form.save).to be(true)
          expect(multi_step_form_session.answers).to eq(before_answers)
        end
      end

      context 'and differs from the value in the session (changed)' do
        before do
          multi_step_form_session[:request_type] = 'non_standard_mag'
          multi_step_form_session[:some_other_answer] = 'wipe-me'
        end

        it 'resets answers, writes current attributes, and returns true' do
          expect(form.save).to be(true)

          expect(multi_step_form_session.answers).to eq(
            'request_type' => 'assigned_counsel'
          )
        end
      end
    end
  end
end
