require 'rails_helper'

RSpec.describe Decisions::DecisionTree do
  # minimal form object that CustomWrapper can wrap
  before do
    stub_const('FormObject', Struct.new(:multi_step_form_session, keyword_init: true))
  end

  let(:multi_step_form_session) { {} }
  let(:form) { FormObject.new(multi_step_form_session:) }

  describe '#destination' do
    context 'from :request_type' do
      context 'when NSM' do
        let(:multi_step_form_session) { { 'request_type' => Payments::ClaimType::NSM.to_s } }

        it_behaves_like 'a generic decision',
                        from: :claim_type,
                        goto: { action: :edit, controller: Decisions::DecisionTree::NSM_CLAIM_DETAILS }
      end

      {
        'NSM_SUPPLEMENTAL' => Payments::ClaimType::NSM_SUPPLEMENTAL,
        'NSM_APPEAL'       => Payments::ClaimType::NSM_APPEAL,
        'NSM_AMENDMENT'    => Payments::ClaimType::NSM_AMENDMENT
      }.each do |label, request_type|
        context "when #{label}" do
          let(:multi_step_form_session) { { 'request_type' => request_type.to_s } }

          it_behaves_like 'a generic decision',
                          from: :claim_type,
                          goto: { action: :edit, controller: Decisions::DecisionTree::CLAIM_SEARCH }
        end
      end
    end

    context 'from :claim_search' do
      {
        'NSM_SUPPLEMENTAL' => Payments::ClaimType::NSM_SUPPLEMENTAL,
        'NSM_APPEAL'       => Payments::ClaimType::NSM_APPEAL,
        'NSM_AMENDMENT'    => Payments::ClaimType::NSM_AMENDMENT
      }.each do |label, request_type|
        context "when #{label}" do
          let(:multi_step_form_session) { { 'request_type' => request_type.to_s } }

          it_behaves_like 'a generic decision',
                          from: :claim_search,
                          goto: { action: :edit, controller: Decisions::DecisionTree::DATE_RECEIVED }
        end
      end
    end

    context 'from :date_received' do
      context 'when NSM supplemental' do
        let(:multi_step_form_session) { { 'request_type' => Payments::ClaimType::NSM_SUPPLEMENTAL.to_s } }

        it_behaves_like 'a generic decision',
                        from: :date_received,
                        goto: { action: :edit, controller: Decisions::DecisionTree::NSM_CLAIMED_COSTS }
      end

      {
        'NSM_APPEAL'    => Payments::ClaimType::NSM_APPEAL,
        'NSM_AMENDMENT' => Payments::ClaimType::NSM_AMENDMENT
      }.each do |label, request_type|
        context "when #{label}" do
          let(:multi_step_form_session) { { 'request_type' => request_type.to_s } }

          it_behaves_like 'a generic decision',
                          from: :date_received,
                          goto: { action: :edit, controller: Decisions::DecisionTree::NSM_ALLOWED_COSTS }
        end
      end
    end

    context 'from :nsm_claim_details' do
      {
        'NSM_APPEAL'    => Payments::ClaimType::NSM_APPEAL,
        'NSM_AMENDMENT' => Payments::ClaimType::NSM_AMENDMENT
      }.each do |label, request_type|
        context "when #{label}" do
          let(:multi_step_form_session) { { 'request_type' => request_type.to_s } }

          it_behaves_like 'a generic decision',
                          from: :nsm_claim_details,
                          goto: { action: :edit, controller: Decisions::DecisionTree::NSM_ALLOWED_COSTS }
        end
      end

      {
        'NSM' => Payments::ClaimType::NSM,
        'NSM_SUPPLEMENTAL' => Payments::ClaimType::NSM_SUPPLEMENTAL
      }.each do |label, request_type|
        context "when #{label}" do
          let(:multi_step_form_session) { { 'request_type' => request_type.to_s } }

          it_behaves_like 'a generic decision',
                          from: :nsm_claim_details,
                          goto: { action: :edit, controller: Decisions::DecisionTree::NSM_CLAIMED_COSTS }
        end
      end
    end

    it_behaves_like 'a generic decision',
                    from: :nsm_claimed_costs,
                    goto: { action: :edit, controller: Decisions::DecisionTree::NSM_ALLOWED_COSTS }

    it_behaves_like 'a generic decision',
                    from: :nsm_allowed_costs,
                    goto: { action: :edit, controller: Decisions::DecisionTree::CHECK_YOUR_ANSWERS }

    it_behaves_like 'a generic decision',
                    from: :check_your_answers,
                    goto: { action: :show, controller: Decisions::DecisionTree::SUBMIT }
  end
end
