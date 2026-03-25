require 'rails_helper'

RSpec.describe Payments::BaseSelectedTransformer do
  subject(:transformer) { described_class.new('claim-id', {}) }

  describe '#claim' do
    it 'raises until a subclass implements claim loading' do
      expect { transformer.send(:claim) }.to raise_error(NotImplementedError, 'Subclasses must implement the claim method')
    end
  end
end
