require 'rails_helper'

RSpec.describe Payments::Steps::OfficeCodeConfirmForm, type: :model do
  subject(:form) do
    described_class.new(
      confirm_office_code: confirm_office_code,
      multi_step_form_session: session
    )
  end

  let(:session) { { solicitor_office_code: '1A123B' } }
  let(:office_details) { { 'firmOfficeCode' => '1A123B', 'officeName' => 'Test Firm' } }

  before do
    allow(ProviderData::ProviderDataClient).to receive_message_chain(:new, :office_details)
      .and_return(office_details)
  end

  describe '#save' do
    context 'when confirm_office_code is false' do
      let(:confirm_office_code) { false }

      it 'returns true without updating session' do
        expect(form.save).to be true
        expect(session[:solicitor_firm_name]).to be_nil
      end
    end
  end
end
