require 'rails_helper'

RSpec.describe Nsm::DownloadsController, type: :controller do
  let(:claim) do
    build(:claim)
  end

  let(:download_url) { 'www.test.com' }

  let(:user) { create :caseworker }

  before do
    allow(Claim).to receive(:load_from_app_store).and_return(claim)
    allow(controller).to receive(:current_user).and_return(user)
    allow(LaaCrimeFormsCommon::S3Files).to receive(:temporary_download_url).and_return(download_url)
  end

  describe 'show' do
    it 'renders successfully with correct params' do
      get :show, params: { claim_id: claim.id, id: claim.data['supporting_evidences'].first['id'] }
      expect(response).to redirect_to(download_url)
    end

    it 'raises error with invalid params' do
      expect { get :show, params: { claim_id: 'garbage', id: claim.data['supporting_evidences'].first['id'] } }.to raise_error RuntimeError
    end
  end
end
