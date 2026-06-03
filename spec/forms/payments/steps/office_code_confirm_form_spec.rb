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
  let(:office_code_details) do
    {
      'firmOfficeCode' => '1A123B',
      'officeName' => 'Office Display Name',
      'firm' => { 'firmName' => 'Correct Firm Name' }
    }
  end
  let(:provider_data_client) { instance_double(ProviderData::ProviderDataClient) }

  before do
    multi_step_form_session[:solicitor_office_code] = '1A123B'
    allow(ProviderData::ProviderDataClient).to receive(:new).and_return(provider_data_client)
    allow(provider_data_client).to receive(:contracted_office_details)
      .with('1A123B')
      .and_return(office_code_details)
  end

  describe '#save' do
    it 'persists solicitor_firm_name from firm.firmName' do
      form.save

      expect(multi_step_form_session[:solicitor_firm_name]).to eq('Correct Firm Name')
    end
  end
end
