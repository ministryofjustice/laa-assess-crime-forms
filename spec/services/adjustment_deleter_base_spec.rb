require 'rails_helper'
class TestDummy < AdjustmentDeleterBase
  def submission_scope
    'test'
  end
end

RSpec.describe AdjustmentDeleterBase do
  subject { TestDummy.new(params, :work_item, user, claim) }

  let(:params) { { claim_id: claim.id, id: item_id } }
  let(:item_id) { 'd8fde347-ce4c-4f85-a3f8-54dca7c0dfc4' }
  let(:user) { create(:caseworker) }
  let(:claim) { build(:claim, data:) }
  let(:data) { build(:nsm_data, :with_adjustments) }

  describe '.call' do
    it 'raise exception if not defined' do
      expect { subject.call }.to raise_error(NotImplementedError)
    end
  end
end
