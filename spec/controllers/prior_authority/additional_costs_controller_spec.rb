require 'rails_helper'

RSpec.describe PriorAuthority::AdditionalCostsController, type: :controller do
  let(:application) { build(:prior_authority_application) }

  describe 'edit' do
    it 'raises error if id not a uuid' do
      expect { get :edit, params: { application_id: application.id, id: 'garbage' } }.to raise_error RuntimeError
    end
  end
end
