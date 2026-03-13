require 'rails_helper'

RSpec.describe ApplicationPolicy do
  subject(:policy) { described_class.new(nil, nil) }

  describe '#index?' do
    it 'is false by default' do
      expect(policy.index?).to be(false)
    end
  end

  describe '#show?' do
    it 'is false by default' do
      expect(policy.show?).to be(false)
    end
  end
end
