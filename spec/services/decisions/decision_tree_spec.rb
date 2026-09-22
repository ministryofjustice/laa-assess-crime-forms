require 'rails_helper'

RSpec.describe Decisions::DecisionTree do
  # minimal form object that CustomWrapper can wrap
  before do
    stub_const('FormObject', Struct.new(:multi_step_form_session))
    allow_any_instance_of(AppStoreClient).to receive(:search).and_return(app_store_payment_search)

    allow(multi_step_form_session).to receive(:[]) do |key|
      session_data.fetch(key.to_s)
    end
  end

  let(:form) { FormObject.new(multi_step_form_session:) }
  let(:multi_step_form_session) { instance_double(Decisions::MultiStepFormSession, answers: session_data) }
  let(:session_data) { {} }
  let(:app_store_payment_search) do
    {
      'metadata' => { 'total_results' => 1 }
    }
  end

  describe '#destination' do
    context 'from :request_type' do
      context 'when NSM' do
        let(:session_data) { { 'request_type' => Payments::ClaimType::NSM.to_s } }

        it_behaves_like 'a generic decision',
                        from: :claim_type,
                        goto: { action: :edit, controller: Decisions::DecisionTree::OFFICE_CODE_SEARCH }
      end

      {
        'NSM_SUPPLEMENTAL' => Payments::ClaimType::NSM_SUPPLEMENTAL,
        'NSM_APPEAL'       => Payments::ClaimType::NSM_APPEAL,
        'NSM_AMENDMENT'    => Payments::ClaimType::NSM_AMENDMENT
      }.each do |label, request_type|
        context "when #{label}" do
          let(:session_data) { { 'request_type' => request_type.to_s } }

          it_behaves_like 'a generic decision',
                          from: :claim_type,
                          goto: { action: :edit, controller: Decisions::DecisionTree::CLAIM_SEARCH }
        end
      end
    end

    context 'from :claim_search' do
      context 'when unlinked claim' do
        let(:session_data) { { 'request_type' => current_request_type, 'laa_reference' => nil } }
        let(:current_request_type) { nil }

        {
          'NSM_SUPPLEMENTAL' => Payments::ClaimType::NSM_SUPPLEMENTAL,
          'NSM_APPEAL'       => Payments::ClaimType::NSM_APPEAL,
          'NSM_AMENDMENT'    => Payments::ClaimType::NSM_AMENDMENT,
          'AC'               => Payments::ClaimType::AC,
          'AC_APPEAL'        => Payments::ClaimType::AC_APPEAL,
          'AC_AMENDMENT'     => Payments::ClaimType::AC_AMENDMENT
        }.each do |label, request_type|
          context "when #{label}" do
            let(:current_request_type) { request_type.to_s }

            it_behaves_like 'a generic decision',
                            from: :claim_search,
                            goto: { action: :edit, controller: Decisions::DecisionTree::OFFICE_CODE_SEARCH }
          end
        end
      end

      context 'when linked claim' do
        let(:session_data) { { 'request_type' => current_request_type, 'laa_reference' => 'some_reference' } }
        let(:current_request_type) { nil }

        context 'when AC' do
          let(:current_request_type) { Payments::ClaimType::AC.to_s }

          it_behaves_like 'a generic decision',
                          from: :claim_search,
                          goto: { action: :edit, controller: Decisions::DecisionTree::COUNSEL_CODE_SEARCH }
        end

        {
          'NSM_SUPPLEMENTAL' => Payments::ClaimType::NSM_SUPPLEMENTAL,
          'NSM_APPEAL'       => Payments::ClaimType::NSM_APPEAL,
          'NSM_AMENDMENT'    => Payments::ClaimType::NSM_AMENDMENT
        }.each do |label, request_type|
          context "when #{label}" do
            let(:current_request_type) { request_type.to_s }

            it_behaves_like 'a generic decision',
                            from: :claim_search,
                            goto: { action: :edit, controller: Decisions::DecisionTree::DATE_CLAIM_ASSESSED }
          end
        end
      end
    end

    context 'from :date_claim_assessed' do
      context 'when NSM supplemental and not linked to an original payment' do
        let(:session_data) { { 'request_type' => Payments::ClaimType::NSM_SUPPLEMENTAL.to_s } }
        let(:app_store_payment_search) { { 'metadata' => { 'total_results' => 0 } } }

        it_behaves_like 'a generic decision',
                        from: :date_claim_assessed,
                        goto: { action: :edit, controller: Decisions::DecisionTree::NSM_ALLOWED_COSTS }
      end

      context 'when NSM supplemental and linked to an original payment' do
        let(:session_data) { { 'request_type' => Payments::ClaimType::NSM_SUPPLEMENTAL.to_s, 'laa_reference' => 'some_reference' } }
        let(:app_store_payment_search) { { 'metadata' => { 'total_results' => 1 } } }

        it_behaves_like 'a generic decision',
                        from: :date_claim_assessed,
                        goto: { action: :edit, controller: Decisions::DecisionTree::NSM_CLAIMED_COSTS }
      end

      {
        'NSM_APPEAL'    => Payments::ClaimType::NSM_APPEAL,
        'NSM_AMENDMENT' => Payments::ClaimType::NSM_AMENDMENT
      }.each do |label, request_type|
        context "when #{label} and unlinked" do
          let(:session_data) { { 'request_type' => request_type.to_s } }

          it_behaves_like 'a generic decision',
                          from: :date_claim_assessed,
                          goto: { action: :edit, controller: Decisions::DecisionTree::NSM_ALLOWED_COSTS }
        end
      end
    end

    context 'from :ac_claim_details' do
      context 'when AC' do
        let(:session_data) { { 'request_type' => Payments::ClaimType::AC.to_s } }

        it_behaves_like 'a generic decision',
                        from: :ac_claim_details,
                        goto: { action: :edit, controller: Decisions::DecisionTree::AC_CLAIMED_COSTS }
      end

      {
        'AC_APPEAL'    => Payments::ClaimType::AC_APPEAL,
        'AC_AMENDMENT' => Payments::ClaimType::AC_AMENDMENT
      }.each do |label, request_type|
        context "when #{label}" do
          let(:session_data) { { 'request_type' => request_type.to_s } }

          it_behaves_like 'a generic decision',
                          from: :ac_claim_details,
                          goto: { action: :edit, controller: Decisions::DecisionTree::AC_ALLOWED_COSTS }
        end
      end
    end

    context 'from :nsm_claim_details' do
      {
        'NSM_APPEAL'    => Payments::ClaimType::NSM_APPEAL,
        'NSM_AMENDMENT' => Payments::ClaimType::NSM_AMENDMENT
      }.each do |label, request_type|
        context "when #{label}" do
          let(:session_data) { { 'request_type' => request_type.to_s } }

          it_behaves_like 'a generic decision',
                          from: :nsm_claim_details,
                          goto: { action: :edit, controller: Decisions::DecisionTree::NSM_ALLOWED_COSTS }
        end
      end

      context 'when NSM' do
        let(:session_data) { { 'request_type' => Payments::ClaimType::NSM.to_s } }

        it_behaves_like 'a generic decision',
                        from: :nsm_claim_details,
                        goto: { action: :edit, controller: Decisions::DecisionTree::NSM_CLAIMED_COSTS }
      end

      context 'when NSM_SUPPLEMENTAL and not linked to an original payment' do
        let(:session_data) { { 'request_type' => Payments::ClaimType::NSM_SUPPLEMENTAL.to_s, :laa_reference => 'some_reference' } }
        let(:app_store_payment_search) do
          {
            'metadata' => { 'total_results' => 0 }
          }
        end

        it_behaves_like 'a generic decision',
                        from: :nsm_claim_details,
                        goto: { action: :edit, controller: Decisions::DecisionTree::NSM_ALLOWED_COSTS }
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
