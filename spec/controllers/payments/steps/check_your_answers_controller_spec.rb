# spec/controllers/payments/steps/check_your_answers_controller_spec.rb
require 'rails_helper'

RSpec.describe Payments::Steps::CheckYourAnswersController, type: :controller do
  let(:id) { SecureRandom.uuid }
  let(:answers) { {} }

  before do
    fake_session = double(
      'Session',
      :answers => answers,
      :[] => request_type
    )
    allow(controller).to receive(:params).and_return({ id: id })
    allow(controller).to receive(:multi_step_form_session).and_return(fake_session)
  end

  {
    'non_standard_magistrate' => Payments::CostsSummary,
    'non_standard_mag_supplemental' => Payments::CostsSummaryAmendedAndClaimed,
    'non_standard_mag_amendment' => Payments::CostsSummaryAmended,
    'non_standard_mag_appeal' => Payments::CostsSummaryAmended
  }.each do |type, klass|
    context "when request_type is '#{type}'" do
      let(:request_type) { type }

      it "initializes #{klass} with answers" do
        expect(klass).to receive(:new).with(answers, id)
        get :edit, params: { id: id }
      end
    end
  end
end
