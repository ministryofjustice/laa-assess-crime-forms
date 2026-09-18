require 'rails_helper'

RSpec.describe Decisions::BackDecisionTree do
  # minimal form object that wrapper delegates to
  before do
    stub_const('FormObject', Struct.new(:multi_step_form_session))
    allow_any_instance_of(AppStoreClient).to receive(:search).and_return(app_store_payment_search)

    allow(multi_step_form_session).to receive(:[]) do |key|
      session_data.fetch(key.to_s)
    end
  end

  let(:multi_step_form_session) { instance_double(Decisions::MultiStepFormSession, answers: session_data) }
  let(:session_data) { {} }
  let(:form) { FormObject.new(multi_step_form_session:) }
  let(:app_store_payment_search) do
    {
      'metadata' => { 'total_results' => 1 }
    }
  end

  describe '#destination' do
    context 'from NSM_CLAIM_DETAILS' do
      context 'when NSM' do
        let(:session_data) { { 'request_type' => Payments::ClaimType::NSM.to_s } }

        it_behaves_like 'a generic decision',
                        from: Decisions::DecisionTree::NSM_CLAIM_DETAILS,
                        goto: { action: :edit, controller: Decisions::DecisionTree::OFFICE_CODE_SEARCH }
      end
    end

    context 'from CLAIM_SEARCH' do
      {
        'NSM_SUPPLEMENTAL' => Payments::ClaimType::NSM_SUPPLEMENTAL,
        'NSM_APPEAL'       => Payments::ClaimType::NSM_APPEAL,
        'NSM_AMENDMENT'    => Payments::ClaimType::NSM_AMENDMENT
      }.each do |label, request_type|
        context "when #{label}" do
          let(:session_data) { { 'request_type' => request_type.to_s } }

          it_behaves_like 'a generic decision',
                          from: Decisions::DecisionTree::CLAIM_SEARCH.sub(%r{^/}, ''),
                          goto: { action: :edit, controller: Decisions::DecisionTree::CLAIM_TYPE }
        end
      end
    end

    context 'from DATE_CLAIM_ASSESSED (leading slash removed)' do
      context 'when NSM_SUPPLEMENTAL with a reference' do
        let(:session_data) do
          { 'request_type' => Payments::ClaimType::NSM_SUPPLEMENTAL.to_s, 'laa_reference' => 'some_reference' }
        end

        it_behaves_like 'a generic decision',
                        from: Decisions::DecisionTree::DATE_CLAIM_ASSESSED.sub(%r{^/}, ''),
                        goto: { action: :edit, controller: Decisions::DecisionTree::CLAIM_SEARCH.sub(%r{^/}, '') }
      end
    end

    context 'from NSM_CLAIMED_COSTS' do
      context 'when NSM' do
        let(:session_data) { { 'request_type' => Payments::ClaimType::NSM.to_s } }

        it_behaves_like 'a generic decision',
                        from: Decisions::DecisionTree::NSM_CLAIMED_COSTS,
                        goto: { action: :edit, controller: Decisions::DecisionTree::NSM_CLAIM_DETAILS }
      end

      context 'when NSM_SUPPLEMENTAL with no existing ref' do
        let(:session_data) { { 'request_type' => Payments::ClaimType::NSM_SUPPLEMENTAL.to_s } }
        let(:app_store_payment_search) { { 'metadata' => { 'total_results' => 0 } } }

        it_behaves_like 'a generic decision',
                        from: Decisions::DecisionTree::NSM_ALLOWED_COSTS,
                        goto: { action: :edit, controller: Decisions::DecisionTree::NSM_CLAIM_DETAILS }
      end
    end

    context 'from NSM_ALLOWED_COSTS' do
      context 'when NSM payment' do
        let(:session_data) { { 'request_type' => Payments::ClaimType::NSM.to_s } }

        it_behaves_like 'a generic decision',
                        from: Decisions::DecisionTree::NSM_ALLOWED_COSTS,
                        goto: { action: :edit, controller: Decisions::DecisionTree::NSM_CLAIMED_COSTS }
      end

      context 'when NSM_SUPPLEMENTAL linked to an existing NSM claim' do
        let(:session_data) { { 'request_type' => Payments::ClaimType::NSM_SUPPLEMENTAL.to_s, 'laa_reference' => 'some_linked_reference' } }

        it_behaves_like 'a generic decision',
                        from: Decisions::DecisionTree::NSM_ALLOWED_COSTS,
                        goto: { action: :edit, controller: Decisions::DecisionTree::NSM_CLAIMED_COSTS }
      end

      context 'when NSM_SUPPLEMENTAL with no existing reference' do
        let(:session_data) { { 'request_type' => Payments::ClaimType::NSM_SUPPLEMENTAL.to_s } }
        let(:app_store_payment_search) { { 'metadata' => { 'total_results' => 0 } } }

        it_behaves_like 'a generic decision',
                        from: Decisions::DecisionTree::NSM_ALLOWED_COSTS,
                        goto: { action: :edit, controller: Decisions::DecisionTree::NSM_CLAIM_DETAILS }
      end

      context 'when NSM_APPEAL with no existing ref' do
        let(:session_data) { { 'laa_reference' => nil, 'linked_laa_reference' => nil, 'request_type' => Payments::ClaimType::NSM_APPEAL.to_s } }

        it_behaves_like 'a generic decision',
                        from: Decisions::DecisionTree::NSM_ALLOWED_COSTS,
                        goto: { action: :edit, controller: Decisions::DecisionTree::NSM_CLAIM_DETAILS }
      end
    end

    context 'from COUNSEL_CODE_CONFIRM' do
      it_behaves_like 'a generic decision',
                      from: Decisions::DecisionTree::COUNSEL_CODE_CONFIRM.sub(%r{^/}, ''),
                      goto: { action: :edit, controller: Decisions::DecisionTree::COUNSEL_CODE_SEARCH }
    end

    context 'from COUNSEL_CODE_SEARCH' do
      context 'when no existing ref' do
        let(:session_data) do
          {
            'laa_reference' => nil,
            'linked_laa_reference' => nil,
            'linked_nsm_reference' => nil,
            'request_type' => Payments::ClaimType::AC.to_s
          }
        end

        it_behaves_like 'a generic decision',
                        from: Decisions::DecisionTree::COUNSEL_CODE_SEARCH.sub(%r{^/}, ''),
                        goto: { action: :edit, controller: Decisions::DecisionTree::OFFICE_CODE_CONFIRM }
      end

      context 'when existing ref' do
        let(:session_data) do
          {
            'laa_reference' => 'some-reference',
            'request_type' => Payments::ClaimType::AC.to_s
          }
        end

        it_behaves_like 'a generic decision',
                        from: Decisions::DecisionTree::COUNSEL_CODE_SEARCH.sub(%r{^/}, ''),
                        goto: { action: :edit, controller: Decisions::DecisionTree::CLAIM_SEARCH.sub(%r{^/}, '') }
      end
    end

    context 'from CHECK_YOUR_ANSWERS' do
      context 'when NSM' do
        let(:session_data) { { 'request_type' => Payments::ClaimType::NSM.to_s } }

        it_behaves_like 'a generic decision',
                        from: Decisions::DecisionTree::CHECK_YOUR_ANSWERS.sub(%r{^/}, ''),
                        goto: { action: :edit, controller: Decisions::DecisionTree::NSM_ALLOWED_COSTS }
      end
    end

    context 'when step has no matching rule' do
      it_behaves_like 'a generic decision',
                      from: 'unknown-step',
                      goto: { action: :index, controller: '/payments/requests' }
    end
  end
end
