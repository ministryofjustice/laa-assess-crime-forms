require 'rails_helper'

RSpec.describe User do
  describe '#caseworker?' do
    context 'when the user has a caseworker role' do
      let(:user) { create(:caseworker) }

      it 'returns true' do
        expect(user.caseworker?).to be true
      end
    end

    context 'when the user does not have a caseworker role' do
      let(:user) { create(:viewer) }

      it 'returns false' do
        expect(user.caseworker?).to be false
      end
    end
  end
end
