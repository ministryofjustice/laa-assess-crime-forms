require 'rails_helper'

RSpec.describe Payments::Steps::OfficeCodeSearchForm, type: :model do
  subject(:form) do
    described_class.new(solicitor_office_code:, multi_step_form_session:)
  end

  let(:solicitor_office_code) { '1A123B' }
  let(:rack_session_hash) { {} }
  let(:multi_step_form_session) do
    Decisions::MultiStepFormSession.new(
      process: 'payments',
      session: rack_session_hash,
      session_id: 'test-session'
    )
  end
  let(:provider_data_client) { instance_double(ProviderData::ProviderDataClient) }

  before do
    allow(ProviderData::ProviderDataClient).to receive(:new).and_return(provider_data_client)
    allow(provider_data_client).to receive(:contracted_office_details).with('1A123B').and_return(
      {
        'firmOfficeCode' => '1A123B',
        'firm' => { 'firmName' => 'Correct Firm Name' }
      }
    )
  end

  describe '#save' do
    context 'when input is invalid' do
      let(:solicitor_office_code) { '' }

      it 'does not persist and adds a validation error' do
        expect(form.save).to be(false)
        expect(form.errors.of_kind?(:solicitor_office_code, :blank)).to be(true)
      end
    end

    context 'when PDA is unavailable' do
      before do
        allow(provider_data_client).to receive(:contracted_office_details).with('1A123B').and_raise(
          ProviderData::ProviderDataApiClient::ProviderUnavailableError, 'PDA unavailable'
        )
      end

      it 'does not persist and adds a provider unavailable error' do
        expect(form.save).to be(false)
        expect(form.errors.of_kind?(:base, :provider_unavailable)).to be(true)
      end
    end

    context 'when PDA is available' do
      it 'persists office code and firm name' do
        expect(form.save).to be(true)
        expect(multi_step_form_session[:solicitor_office_code]).to eq('1A123B')
        expect(multi_step_form_session[:solicitor_firm_name]).to eq('Correct Firm Name')
        expect(multi_step_form_session[:solicitor_office_code_details]).to be_nil
      end
    end

    context 'when PDA returns no office details' do
      before do
        allow(provider_data_client).to receive(:contracted_office_details).with('1A123B').and_return(nil)
      end

      it 'persists office code and clears firm name' do
        expect(form.save).to be(true)
        expect(multi_step_form_session[:solicitor_office_code]).to eq('1A123B')
        expect(multi_step_form_session[:solicitor_firm_name]).to eq('')
      end
    end
  end
end
