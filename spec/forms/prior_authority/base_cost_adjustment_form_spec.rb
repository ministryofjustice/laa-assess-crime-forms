require 'rails_helper'

RSpec.describe PriorAuthority::BaseCostAdjustmentForm, type: :model do
  subject(:form) { described_class.new }

  describe '#per_item?' do
    it 'raises not implemented' do
      expect { form.per_item? }.to raise_error('Implement in subclass')
    end
  end

  describe '#per_hour?' do
    it 'raises not implemented' do
      expect { form.per_hour? }.to raise_error('Implement in subclass')
    end
  end

  describe '#process_fields' do
    it 'raises not implemented' do
      expect { form.send(:process_fields) }.to raise_error('Implement in subclass')
    end
  end
end
