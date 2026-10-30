require 'rails_helper'

RSpec.describe Payments::Steps::CounselCodeSearchForm, type: :model do
  subject(:form) do
    described_class.new(counsel_office_code:, multi_step_form_session:)
  end

  let(:counsel_office_code) { '1a123c' }
  let(:rack_session_hash) { {} }
  let(:multi_step_form_session) do
    Decisions::MultiStepFormSession.new(
      process: 'payments',
      session: rack_session_hash,
      session_id: 'test-session'
    )
  end

  describe '#save' do
    it 'persists the uppercase office code' do
      expect(form.save).to eq('1A123C')
      expect(multi_step_form_session[:counsel_office_code]).to eq('1A123C')
    end

    context 'when office code is blank' do
      let(:counsel_office_code) { '' }

      it 'does not persist the office code' do
        expect(form.save).to be(false)
        expect(multi_step_form_session[:counsel_office_code]).to be_nil
      end
    end
  end
end
