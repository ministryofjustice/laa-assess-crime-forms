require 'rails_helper'

RSpec.describe Nsm::AdditionalFeesController do
  let(:rep_order_date) { '2024-12-06' }
  let(:claim) do
    build(:claim, data: data, assigned_user_id: user.id)
  end
  let(:data) do
    build(:nsm_data, youth_court: 'yes',
      claim_type: 'non_standard_magistrate', plea_category: 'category_1a',
      include_youth_court_fee: true, rep_order_date: rep_order_date)
  end

  let(:user) { create :caseworker }
  let(:youth_court_fee) { { type: 'youth_court_fee' } }

  before do
    allow(Claim).to receive(:load_from_app_store).and_return(claim)
    allow(controller).to receive(:current_user).and_return(user)
    allow(claim).to receive(:additional_fees).and_return(
      {
        youth_court_fee: { claimed_total_exc_vat: 598.59 },
        total: { claimed_total_exc_vat: 598.59 }
      }
    )
  end

  context 'No additional fee applicable' do
    let(:rep_order_date) { '2024-12-05' }

    it 'raises error when trying to render' do
      expect { get :index, params: { claim_id: claim.id } }.to raise_error(ActionController::RoutingError)
    end
  end

  describe 'index' do
    it 'renders successfully' do
      get :index, params: { claim_id: claim.id }
      expect(response).to be_successful
    end
  end

  describe 'adjusted' do
    it 'renders successfully' do
      get :adjusted, params: { claim_id: claim.id }
      expect(response).to be_successful
    end
  end

  describe 'show' do
    it 'renders successfully' do
      get :show, params: { claim_id: claim.id, id: youth_court_fee[:type] }
      expect(response).to be_successful
    end
  end

  describe 'edit' do
    it 'renders successfully' do
      get :edit, params: { claim_id: claim.id, id: youth_court_fee[:type] }
      expect(response).to be_successful
    end
  end
end
