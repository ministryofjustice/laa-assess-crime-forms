require 'rails_helper'

RSpec.describe Decisions::BackDecisionTree do
  # minimal form object that wrapper delegates to
  before do
    stub_const('FormObject', Struct.new(:multi_step_form_session, keyword_init: true))
  end

  let(:multi_step_form_session) { {} }
  let(:form) { FormObject.new(multi_step_form_session:) }

  describe '#destination' do
    context 'from NSM_CLAIM_DETAILS' do
      context 'when NSM' do
        let(:multi_step_form_session) { { 'request_type' => Payments::ClaimType::NSM.to_s } }

        it_behaves_like 'a generic decision',
                        from: Decisions::DecisionTree::NSM_CLAIM_DETAILS,
                        goto: { action: :edit, controller: Decisions::DecisionTree::CLAIM_TYPE }
      end
    end

    context 'from CLAIM_SEARCH' do
      {
        'NSM_SUPPLEMENTAL' => Payments::ClaimType::NSM_SUPPLEMENTAL,
        'NSM_APPEAL'       => Payments::ClaimType::NSM_APPEAL,
        'NSM_AMENDMENT'    => Payments::ClaimType::NSM_AMENDMENT
      }.each do |label, request_type|
        context "when #{label}" do
          let(:multi_step_form_session) { { 'request_type' => request_type.to_s } }

          it_behaves_like 'a generic decision',
                          from: Decisions::DecisionTree::CLAIM_SEARCH.sub(%r{^/}, ''),
                          goto: { action: :edit, controller: Decisions::DecisionTree::CLAIM_TYPE }
        end
      end
    end

    context 'from DATE_RECEIVED (leading slash removed)' do
      let(:multi_step_form_session) do
        { 'request_type' => Payments::ClaimType::NSM_SUPPLEMENTAL.to_s,
          'laa_reference_check' => true }
      end

      it_behaves_like 'a generic decision',
                      from: Decisions::DecisionTree::DATE_RECEIVED.sub(%r{^/}, ''),
                      goto: { action: :edit, controller: Decisions::DecisionTree::CLAIM_SEARCH.sub(%r{^/}, '') }
    end

    context 'from NSM_CLAIMED_COSTS' do
      context 'when NSM' do
        let(:multi_step_form_session) { { 'request_type' => Payments::ClaimType::NSM.to_s } }

        it_behaves_like 'a generic decision',
                        from: Decisions::DecisionTree::NSM_CLAIMED_COSTS,
                        goto: { action: :edit, controller: Decisions::DecisionTree::NSM_CLAIM_DETAILS }
      end

      context 'when supplemental with laa_reference_check true' do
        let(:multi_step_form_session) do
          { 'request_type' => Payments::ClaimType::NSM_SUPPLEMENTAL.to_s,
            'laa_reference_check' => true }
        end

        it_behaves_like 'a generic decision',
                        from: Decisions::DecisionTree::NSM_CLAIMED_COSTS,
                        goto: { action: :edit, controller: Decisions::DecisionTree::DATE_RECEIVED }
      end

      context 'when supplemental with laa_reference_check false' do
        let(:multi_step_form_session) do
          { 'request_type' => Payments::ClaimType::NSM_SUPPLEMENTAL.to_s }
        end

        it_behaves_like 'a generic decision',
                        from: Decisions::DecisionTree::NSM_CLAIMED_COSTS,
                        goto: { action: :edit, controller: Decisions::DecisionTree::DATE_RECEIVED }
      end
    end

    context 'from NSM_ALLOWED_COSTS' do
      {
        'NSM' => Payments::ClaimType::NSM,
        'NSM_SUPPLEMENTAL' => Payments::ClaimType::NSM_SUPPLEMENTAL
      }.each do |label, request_type|
        context "when #{label}" do
          let(:multi_step_form_session) { { 'request_type' => request_type.to_s } }

          it_behaves_like 'a generic decision',
                          from: Decisions::DecisionTree::NSM_ALLOWED_COSTS,
                          goto: { action: :edit, controller: Decisions::DecisionTree::NSM_CLAIMED_COSTS }
        end
      end

      {
        'NSM_APPEAL'    => Payments::ClaimType::NSM_APPEAL,
        'NSM_AMENDMENT' => Payments::ClaimType::NSM_AMENDMENT
      }.each do |label, request_type|
        context "when #{label} with laa_reference_check true" do
          let(:multi_step_form_session) do
            { 'request_type' => request_type.to_s, 'laa_reference_check' => true }
          end

          it_behaves_like 'a generic decision',
                          from: Decisions::DecisionTree::NSM_ALLOWED_COSTS,
                          goto: { action: :edit, controller: Decisions::DecisionTree::DATE_RECEIVED }
        end

        context "when #{label} with laa_reference_check false" do
          let(:multi_step_form_session) do
            { 'request_type' => request_type.to_s }
          end

          it_behaves_like 'a generic decision',
                          from: Decisions::DecisionTree::NSM_ALLOWED_COSTS,
                          goto: { action: :edit, controller: Decisions::DecisionTree::DATE_RECEIVED }
        end
      end
    end

    context 'from CHECK_YOUR_ANSWERS' do
      it_behaves_like 'a generic decision',
                      from: Decisions::BackDecisionTree::CHECK_YOUR_ANSWERS,
                      goto: { action: :edit, controller: Decisions::DecisionTree::NSM_ALLOWED_COSTS }
    end

    context 'when step has no matching rule' do
      it_behaves_like 'a generic decision',
                      from: 'unknown-step',
                      goto: { action: :index, controller: '/payments/requests' }
    end
  end
end
