# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payments::ReturnToCya, type: :controller do
  # Use the real base so multi_step_form_session exists; we override it in before
  controller(Payments::Steps::BaseController) do
    def index
      head :ok
    end
  end

  let(:session_store) { {} }
  let(:multi_step_form_session) { ActiveSupport::HashWithIndifferentAccess.new(session_store) }

  before do
    allow(controller).to receive(:multi_step_form_session).and_return(multi_step_form_session)
  end

  describe '#return_to_cya?' do
    it 'returns true when session return_to is check_your_answers' do
      multi_step_form_session['return_to'] = 'check_your_answers'
      expect(controller.send(:return_to_cya?)).to be true
    end

    it 'returns false when session return_to is blank' do
      multi_step_form_session['return_to'] = nil
      expect(controller.send(:return_to_cya?)).to be false
    end

    it 'returns false when session return_to is something else' do
      multi_step_form_session['return_to'] = 'other'
      expect(controller.send(:return_to_cya?)).to be false
    end
  end

  describe '#clear_return_to_cya!' do
    it 'clears the return_to key in session' do
      multi_step_form_session['return_to'] = 'check_your_answers'
      controller.send(:clear_return_to_cya!)
      expect(multi_step_form_session['return_to']).to be_nil
    end
  end

  describe '#store_return_to_from_params' do
    it 'stores params[:return_to] in session when present' do
      get :index, params: { return_to: 'check_your_answers' }
      controller.send(:store_return_to_from_params)
      expect(multi_step_form_session['return_to']).to eq('check_your_answers')
    end

    it 'does not overwrite session when params[:return_to] is blank' do
      multi_step_form_session['return_to'] = 'check_your_answers'
      get :index, params: {}
      controller.send(:store_return_to_from_params)
      expect(multi_step_form_session['return_to']).to eq('check_your_answers')
    end
  end
end
