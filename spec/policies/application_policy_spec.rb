require 'rails_helper'

RSpec.describe ApplicationPolicy do
  subject(:policy) { described_class.new(nil, nil) }

  describe 'default permissions' do
    it 'is restrictive by default' do
      expect(policy.index?).to be(false)
      expect(policy.show?).to be(false)
      expect(policy.create?).to be(false)
      expect(policy.new?).to be(false)
      expect(policy.update?).to be(false)
      expect(policy.edit?).to be(false)
      expect(policy.destroy?).to be(false)
    end
  end
end
