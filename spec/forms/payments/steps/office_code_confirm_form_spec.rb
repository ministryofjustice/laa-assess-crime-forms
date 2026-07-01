require 'rails_helper'

RSpec.describe Payments::Steps::OfficeCodeConfirmForm, type: :model do
  subject(:form) do
    described_class.new(confirm_office_code:, multi_step_form_session:)
  end

  let(:confirm_office_code) { true }
  let(:rack_session_hash) { {} }
  let(:multi_step_form_session) do
    Decisions::MultiStepFormSession.new(
      process: 'payments',
      session: rack_session_hash,
      session_id: 'test-session'
    )
  end

  before do
    multi_step_form_session[:solicitor_office_code] = '1A123B'
    multi_step_form_session[:solicitor_firm_name] = 'Correct Firm Name'
  end

  describe '#office_code_details' do
    it 'builds office details from session values' do
      expect(form.office_code_details).to eq(
        {
          'firmOfficeCode' => '1A123B',
          'firm' => { 'firmName' => 'Correct Firm Name' }
        }
      )
    end

    context 'when searched code is blank' do
      before do
        multi_step_form_session[:solicitor_office_code] = nil
      end

      it 'returns nil' do
        expect(form.office_code_details).to be_nil
      end
    end

    context 'when firm name is blank' do
      before do
        multi_step_form_session[:solicitor_firm_name] = nil
      end

      it 'returns nil' do
        expect(form.office_code_details).to be_nil
      end
    end
  end

  describe '#save' do
    it 'persists solicitor_firm_name' do
      form.save

      expect(multi_step_form_session[:solicitor_firm_name]).to eq('Correct Firm Name')
    end
  end
end
