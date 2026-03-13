require 'rails_helper'

RSpec.describe Payments::Steps::OfficeCodeConfirmController, type: :controller do
  describe '#update' do
    it 'delegates to return-to-cya handling when the office is confirmed' do
      allow(controller).to receive(:params).and_return(
        ActionController::Parameters.new(
          id: SecureRandom.uuid,
          payments_steps_office_code_confirm_form: { confirm_office_code: 'true' }
        )
      )

      expect(controller).to receive(:update_with_return_to_cya).with(
        Payments::Steps::OfficeCodeConfirmForm,
        as: :office_code_confirm,
        success_redirect: :decision_tree
      ).and_return(true)

      controller.update
    end
  end
end
