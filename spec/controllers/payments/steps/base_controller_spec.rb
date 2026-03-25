require 'rails_helper'

RSpec.describe Payments::Steps::BaseController, type: :controller do
  controller(described_class) do
    def index
      head :ok
    end
  end

  let(:fake_session) { instance_double(Decisions::MultiStepFormSession) }

  before do
    allow(controller).to receive(:multi_step_form_session).and_return(fake_session)
  end

  describe '#parent_claim_class' do
    it 'maps non-standard magistrate variants to non_standard_magistrate' do
      allow(fake_session).to receive(:[]).with('request_type').and_return('non_standard_mag_appeal')

      expect(controller.send(:parent_claim_class)).to eq(:non_standard_magistrate)
    end

    it 'maps breach of injunction to non_standard_magistrate' do
      allow(fake_session).to receive(:[]).with('request_type').and_return('breach_of_injunction')

      expect(controller.send(:parent_claim_class)).to eq(:non_standard_magistrate)
    end

    it 'maps assigned counsel variants to assigned_counsel' do
      allow(fake_session).to receive(:[]).with('request_type').and_return('assigned_counsel_amendment')

      expect(controller.send(:parent_claim_class)).to eq(:assigned_counsel)
    end
  end
end
