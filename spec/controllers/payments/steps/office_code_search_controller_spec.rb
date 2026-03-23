require 'rails_helper'

RSpec.describe Payments::Steps::OfficeCodeSearchController, type: :controller do
  let(:fake_session) { instance_double(Decisions::MultiStepFormSession) }

  before do
    allow(controller).to receive(:multi_step_form_session).and_return(fake_session)
    allow(fake_session).to receive(:answers).and_return({})
    allow(fake_session).to receive(:[]=)
  end

  describe 'GET #edit' do
    it 'stores return_to in the multi step session when present' do
      get :edit, params: { id: SecureRandom.uuid, return_to: 'check_your_answers' }

      expect(fake_session).to have_received(:[]=).with('return_to', 'check_your_answers')
    end
  end
end
