require 'rails_helper'

RSpec.describe Payments::Steps::Nsm::ClaimDetailForm, type: :model do
  subject(:form) do
    described_class.new(
      date_received: '2026-01-01',
      ufn: '010123/001',
      stage_reached: 'PROG',
      defendant_first_name: 'John',
      defendant_last_name: 'Doe',
      number_of_defendants: 2,
      number_of_attendances: 3,
      hearing_outcome_code: 'CP19',
      matter_type: '13',
      court_id: court_id,
      court_name: court_name,
      court_name_suggestion: court_name_suggestion,
      youth_court: true,
      date_completed: '2026-01-02',
      multi_step_form_session: session_store
    )
  end

  let(:court_id) { 'C3208F' }
  let(:court_name_suggestion) { 'USK' }
  let(:court_name) { 'USK' }
  let(:session_store) { {} }

  describe 'validations' do
    it 'is valid with all required values present' do
      expect(form).to be_valid
    end
  end

  describe '#save' do
    context 'with valid attributes' do
      it 'returns true' do
        expect(form.save).to be true
      end

      it 'stores claim details in session' do
        form.save
        expect(session_store).to include(
          date_received: Date.new(2026, 1, 1),
          ufn: '010123/001',
          stage_reached: 'PROG',
          defendant_first_name: 'John',
          defendant_last_name: 'Doe',
          number_of_defendants: 2,
          number_of_attendances: 3,
          hearing_outcome_code: 'CP19',
          matter_type: '13',
          court_id: court_id,
          court_name: court_name,
          youth_court: true,
          date_completed: Date.new(2026, 1, 2)
        )
      end
    end

    context 'when the form is invalid' do
      let(:court_name_suggestion) { nil }
      let(:court_id) { nil }
      let(:court_name) { nil }

      it 'returns false' do
        expect(form.save).to be false
      end

      it 'does not update the session' do
        form.save
        expect(session_store).to be_empty
      end
    end

    context 'when court is taken from suggestion' do
      let(:court_name_suggestion) { 'USK' }
      let(:court_id) { nil }
      let(:court_name) { nil }

      it 'sets court_id and court_name from the suggested court' do
        form.save
        expect(session_store).to include(court_id: 'C3208F', court_name: 'USK')
      end
    end

    context 'when court is custom' do
      let(:court_name_suggestion) { 'Custom Court' }
      let(:court_id) { nil }
      let(:court_name) { nil }

      it 'sets court_id to custom and court_name from the suggestion' do
        form.save
        expect(session_store).to include(court_id: 'custom', court_name: 'Custom Court')
      end
    end
  end
end
