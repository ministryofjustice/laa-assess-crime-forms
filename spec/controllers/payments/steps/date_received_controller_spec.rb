require 'rails_helper'

RSpec.describe Payments::Steps::DateReceivedController, type: :controller do
  describe '#update' do
    it 'delegates to return-to-cya handling for check your answers redirects' do
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(id: SecureRandom.uuid))

      expect(controller).to receive(:update_with_return_to_cya).with(
        Payments::Steps::DateReceivedForm,
        as: :date_received,
        success_redirect: :check_your_answers
      ).and_return(true)

      controller.update
    end
  end
end
