require 'rails_helper'

RSpec.describe Payments::Steps::OfficeCodeSearchController, type: :controller do
  let(:fake_session) { instance_double(Decisions::MultiStepFormSession) }

  before do
    allow(fake_session).to receive(:answers).and_return({ 'id' => 'sub-1' })
    allow(fake_session).to receive(:mark_return_to_cya!)
    allow(controller).to receive(:multi_step_form_session).and_return(fake_session)
    allow(Payments::Steps::OfficeCodeSearchForm).to receive(:build).and_return(instance_double(Payments::Steps::OfficeCodeSearchForm))
  end

  describe 'GET #edit' do
    it 'marks return to CYA when the query param is present' do
      get :edit, params: { id: 'sub-1', return_to_cya: '1' }

      expect(fake_session).to have_received(:mark_return_to_cya!)
    end

    it 'does not mark return to CYA without the query param' do
      get :edit, params: { id: 'sub-1' }

      expect(fake_session).not_to have_received(:mark_return_to_cya!)
    end
  end
end
