require 'rails_helper'

RSpec.describe PriorAuthority::RelatedApplicationsController, type: :controller do
  let(:application) { build(:prior_authority_application) }

  describe 'index' do
    it 'raises error if pagy params invalid' do
      expect do
        get :index, params: {
          application_id: application.id,
          sort_by: 'garbage',
          sort_direction: 'garbage',
          page: -1
        }
      end.to raise_error RuntimeError
    end
  end
end
