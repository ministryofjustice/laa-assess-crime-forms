require 'rails_helper'

RSpec.describe Nsm::ClaimDetailsController do
  context 'show' do
    let(:claim) { build(:claim) }
    let(:claim_id) { claim.id }
    let(:claim_summary) { instance_double(Nsm::V1::ClaimSummary) }
    let(:claim_details) { instance_double(ClaimDetails::Table) }
    let(:provider_updates) { nil }

    before do
      allow(Claim).to receive(:load_from_app_store).and_return(claim)
      allow(BaseViewModel).to receive(:build).with(:claim_summary, claim).and_return(claim_summary)
      allow(ClaimDetails::Table).to receive(:new).and_return(claim_details)
    end

    it 'find and builds the required object' do
      get :show, params: { claim_id: }

      expect(Claim).to have_received(:load_from_app_store).with(claim_id)
      expect(BaseViewModel).to have_received(:build).with(:claim_summary, claim)
    end

    it 'renders successfully' do
      allow(controller).to receive(:render)
      get :show, params: { claim_id: }

      expect(controller).to have_received(:render)
        .with(
          locals: {
            claim: claim,
            claim_summary: claim_summary,
            claim_details: claim_details,
            provider_updates: provider_updates,
            payment_request_eligible: false
          }
        )
      expect(response).to be_successful
    end

    describe 'has further_information' do
      let(:data) { build(:nsm_data, further_information: { 'information_requested' => 'requesting...' }) }
      let(:claim) { build(:claim, data:) }
      let(:further_information) { [instance_double(Nsm::V1::FurtherInformation)] }

      before do
        allow(further_information).to receive(:sort_by).and_return further_information
        allow(BaseViewModel).to receive(:build)
          .with(:further_information, claim, 'further_information')
          .and_return(further_information)
      end

      it 'build the further information object array and sort_by' do
        get :show, params: { claim_id: }

        expect(further_information).to have_received(:sort_by)
      end
    end
  end

  describe 'App Store calls', :stub_oauth_token do
    render_views

    let(:user) { create(:caseworker) }
    let(:auth_user) { user }
    let(:claim) { build(:claim, state: 'granted', assigned_user_id: user.id) }
    let(:claim_id) { claim.id }
    let(:submission_request) do
      stub_request(:get, "https://appstore.example.com/v1/submissions/#{claim.id}")
        .to_return(lambda do |_|
          {
            status: 200,
            body: NotifyAppStore::MessageBuilder.new(submission: claim, validate: false).message.merge(
              version: 1,
              updated_at: claim.updated_at,
              created_at: claim.created_at,
              last_updated_at: claim.app_store_updated_at,
              assigned_user_id: claim.assigned_user_id
            ).to_json
          }
        end)
    end
    let(:payment_request_search) do
      stub_request(:post, 'https://appstore.example.com/v1/payment_requests/searches')
        .with(
          body: {
            page: 1,
            sort_by: 'submitted_at',
            sort_direction: 'descending',
            submission_id: claim.id,
            per_page: 20
          }
        )
        .to_return(
          status: 201,
          body: {
            metadata: { total_results: 0 },
            raw_data: []
          }.to_json
        )
    end

    before do
      allow(FeatureFlags).to receive_messages(payments: double(enabled?: true))
      submission_request
      payment_request_search
    end

    it 'only checks claim and payment request details once when rendering claim details' do
      get :show, params: { claim_id: }

      expect(submission_request).to have_been_requested.once
      expect(payment_request_search).to have_been_requested.once
      expect(response.body).to include('Create payment request')
    end
  end
end
