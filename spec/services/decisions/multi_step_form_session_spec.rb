require 'rails_helper'

RSpec.describe Decisions::MultiStepFormSession do
  subject(:multi_step_form_session) { described_class.new(process:, session:, session_id:) }

  let(:session)    { {} }
  let(:process)    { 'payments' }
  let(:session_id) { 'abc-123' }
  let(:key)        { "#{process}:#{session_id}" }

  describe '#initialize / create!' do
    it 'creates a new namespaced session hash when none exists' do
      multi_step_form_session
      expect(session[key]).to include(
        'answers'    => {}
      )
    end

    it 'does not overwrite when a hash already exists' do
      session[key] = {
        'answers'    => { 'claim_type' => 'nsm' }
      }

      multi_step_form_session

      expect(session[key]['answers']).to eq('claim_type' => 'nsm')
    end
  end

  describe '#answers' do
    it 'returns the answers hash' do
      expect(multi_step_form_session.answers).to eq({})
    end
  end

  describe '#[] and #[]=' do
    it 'reads and writes keys into answers' do
      multi_step_form_session[:profit_costs] = '12.34'
      multi_step_form_session[:travel_costs] = '9.87'

      expect(multi_step_form_session[:profit_costs]).to eq('12.34')
      expect(multi_step_form_session[:travel_costs]).to eq('9.87')
      expect(session[key]['answers']).to eq(
        'profit_costs' => '12.34',
        'travel_costs' => '9.87'
      )
    end
  end

  context 'namespacing' do
    it 'stores under process:session_id key' do
      multi_step_form_session
      expect(session.keys).to contain_exactly(key)
    end
  end
end
