require 'rails_helper'

RSpec.describe BaseAdjustmentForm, type: :model do
  describe '#data_has_changed?' do
    it 'raises not implemented' do
      expect { described_class.new.send(:data_has_changed?) }.to raise_error('implement in class')
    end
  end

  describe '#selected_record' do
    it 'raises not implemented' do
      expect { described_class.new.send(:selected_record) }.to raise_error('implement in class')
    end
  end
end
