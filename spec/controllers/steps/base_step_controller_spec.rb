require 'rails_helper'

RSpec.describe Steps::BaseStepController, type: :controller do
  controller(described_class) do
    def index
      head :ok
    end
  end

  describe '#show' do
    it 'raises not implemented' do
      expect { controller.show }.to raise_error('implement this action, if needed, in subclasses')
    end
  end

  describe '#edit' do
    it 'raises not implemented' do
      expect { controller.edit }.to raise_error('implement this action, if needed, in subclasses')
    end
  end

  describe '#update' do
    it 'raises not implemented' do
      expect { controller.update }.to raise_error('implement this action, if needed, in subclasses')
    end
  end

  describe '#multi_step_form_session' do
    it 'raises not implemented' do
      expect { controller.send(:multi_step_form_session) }.to raise_error('implement this action, in subclasses')
    end
  end

  describe '#decision_tree_class' do
    it 'raises not implemented' do
      expect { controller.send(:decision_tree_class) }.to raise_error('implement this action, in subclasses')
    end
  end
end
