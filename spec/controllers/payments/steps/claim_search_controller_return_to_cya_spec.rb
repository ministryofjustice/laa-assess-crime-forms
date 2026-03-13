require 'rails_helper'

RSpec.describe Payments::Steps::ClaimSearchController, type: :controller do
  let(:fake_session) { instance_double(Decisions::MultiStepFormSession) }
  let(:search_form) { instance_double(Payments::Steps::ClaimSearchForm) }

  before do
    allow(controller).to receive_messages(
      multi_step_form_session: fake_session,
      default_params: { page: '1', request_type: 'non_standard_magistrate' },
      page_heading: 'Heading'
    )
    allow(Payments::Steps::ClaimSearchForm).to receive(:new).and_return(search_form)
  end

  describe '#update' do
    it 'rebuilds the search form when the return-to-cya flow renders edit' do
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(id: SecureRandom.uuid))

      expect(controller).to receive(:update_with_return_to_cya) do |form_class,
                                                                    as:,
                                                                    success_redirect:,
                                                                    render_edit_options:,
                                                                    &block|
        expect(form_class).to eq(Payments::Steps::SelectedClaimForm)
        expect(as).to eq(:claim_search)
        expect(success_redirect).to eq(:decision_tree)
        expect(render_edit_options).to eq(locals: { page_heading: 'Heading' })
        block.call
        true
      end

      controller.update

      expect(Payments::Steps::ClaimSearchForm).to have_received(:new).with(
        page: '1',
        request_type: 'non_standard_magistrate'
      )
    end
  end
end
