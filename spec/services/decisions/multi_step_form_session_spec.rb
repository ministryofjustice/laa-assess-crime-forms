require 'rails_helper'

RSpec.describe Decisions::MultiStepFormSession do
  subject(:multi_step_form_session) { described_class.new(process:, session:, session_id:) }

  let(:session)    { {} }
  let(:process)    { 'payments' }
  let(:session_id) { 'abc-123' }
  let(:key)        { "#{process}:#{session_id}" }

  describe '#initialize / create!' do
    it 'creates a new namespaced session hash with timestamps when none exists' do
      travel_to(Time.zone.parse('2025-01-01 12:00:00')) do
        multi_step_form_session
        expect(session[key]).to include(
          'answers'    => {},
          'created_at' => Time.current.iso8601,
          'updated_at' => Time.current.iso8601
        )
      end
    end

    it 'does not overwrite when an unexpired hash already exists' do
      travel_to(Time.zone.parse('2025-01-01 12:00:00')) do
        session[key] = {
          'answers'    => { 'claim_type' => 'nsm' },
          'created_at' => 30.minutes.ago.iso8601,
          'updated_at' => 5.minutes.ago.iso8601
        }

        multi_step_form_session

        expect(session[key]['answers']).to eq('claim_type' => 'nsm')
        expect(session[key]['created_at']).to eq(30.minutes.ago.iso8601)
        expect(session[key]['updated_at']).to eq(5.minutes.ago.iso8601)
      end
    end

    it 'recreates the hash when the existing one is expired' do
      travel_to(Time.zone.parse('2025-01-01 12:00:00')) do
        session[key] = {
          'answers'    => { 'stale' => true },
          'created_at' => 2.hours.ago.iso8601,
          'updated_at' => 2.hours.ago.iso8601
        }

        multi_step_form_session

        expect(session[key]['answers']).to eq({})
        expect(session[key]['created_at']).to eq(Time.current.iso8601)
        expect(session[key]['updated_at']).to eq(Time.current.iso8601)
      end
    end

    it 'keeps existing data when updated_at is malformed' do
      travel_to(Time.zone.parse('2025-01-01 12:00:00')) do
        session[key] = {
          'answers'    => { 'foo' => 'bar' },
          'created_at' => 2.hours.ago.iso8601,
          'updated_at' => 'not-a-time'
        }

        multi_step_form_session

        expect(session[key]['answers']).to eq('foo' => 'bar')
        expect(session[key]['updated_at']).to eq('not-a-time')
      end
    end
  end

  describe '#answers' do
    it 'returns the answers hash' do
      travel_to(Time.zone.parse('2025-01-01 12:00:00')) do
        expect(multi_step_form_session.answers).to eq({})
      end
    end
  end

  describe '#[] and #[]=' do
    it 'reads and writes keys into answers' do
      travel_to(Time.zone.parse('2025-01-01 12:00:00')) do
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
  end

  context 'namespacing' do
    it 'stores under process:session_id key' do
      travel_to(Time.zone.parse('2025-01-01 12:00:00')) do
        multi_step_form_session
        expect(session.keys).to contain_exactly(key)
      end
    end
  end

  describe '#expired?' do
    def call_expired(hash)
      multi_step_form_session.send(:expired?, hash)
    end

    it 'returns false when updated_at is within the window (e.g., 59 minutes ago)' do
      travel_to(Time.zone.parse('2025-01-01 12:00:00')) do
        expect(call_expired('updated_at' => 59.minutes.ago.iso8601)).to be(false)
      end
    end

    it 'returns true when updated_at is strictly older than the window' do
      travel_to(Time.zone.parse('2025-01-01 12:00:00')) do
        expect(call_expired('updated_at' => 61.minutes.ago.iso8601)).to be(true)
      end
    end
  end
end
