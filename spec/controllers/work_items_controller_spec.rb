require 'rails_helper'

RSpec.describe WorkItemsController do
  context 'index' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:claim_summary) { instance_double(V1::ClaimSummary) }
    let(:work_items) { [instance_double(V1::WorkItem, completed_on: Date.today)] }
    let(:grouped_work_items) { { Date.today => work_items } }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive(:build).and_return(claim_summary)
      allow(BaseViewModel).to receive(:build_all).and_return(work_items)
    end

    it 'find and builds the required object' do
      get :index, params: { claim_id: }

      expect(Claim).to have_received(:find).with(claim_id)
      expect(BaseViewModel).to have_received(:build).with(:claim_summary, claim)
      expect(BaseViewModel).to have_received(:build_all).with(:work_item, claim, 'work_items')
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :index, params: { claim_id: }

      expect(controller).to have_received(:render).with(locals: { claim:, claim_summary:, work_items: grouped_work_items})
      expect(response).to be_successful
    end
  end
end
