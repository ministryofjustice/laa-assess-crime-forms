require 'rails_helper'

RSpec.describe Payments::Steps::OfficeCodeSearchController, type: :controller do
  let(:fake_session) { instance_double(Decisions::MultiStepFormSession) }

  before do
    allow(controller).to receive(:multi_step_form_session).and_return(fake_session)
  end

  describe '#edit' do
    it 'stores return_to in session when present' do
      allow(fake_session).to receive(:[]=)
      allow(fake_session).to receive(:answers).and_return({})

      get :edit, params: { id: SecureRandom.uuid, return_to: 'check_your_answers' }

      expect(fake_session).to have_received(:[]=).with('return_to', 'check_your_answers')
    end
  end

  describe '#update' do
    it 'delegates to return-to-cya handling with a custom redirect' do
      params = ActionController::Parameters.new(id: SecureRandom.uuid)
      allow(controller).to receive(:params).and_return(params)

      expect(controller).to receive(:update_with_return_to_cya) do |form_class, as:, success_redirect:|
        expect(form_class).to eq(Payments::Steps::OfficeCodeSearchForm)
        expect(as).to eq(:office_code_search)
        expect(success_redirect).to be_a(Proc)
        expect(success_redirect.call).to eq(controller.edit_payments_steps_office_code_confirm_path(id: params[:id]))
        true
      end

      controller.update
    end
  end
end
