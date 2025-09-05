require 'rails_helper'

RSpec.describe TranslationObject do
  subject { described_class.new(value, scope) }

  describe '#translated' do
    context 'when value is nil' do
      let(:value) { nil }
      let(:scope) { nil }

      it { expect(subject.translated).to eq('') }
    end
  end
end
