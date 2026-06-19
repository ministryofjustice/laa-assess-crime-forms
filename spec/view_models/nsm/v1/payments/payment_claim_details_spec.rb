require 'rails_helper'

RSpec.describe Nsm::V1::PaymentClaimDetails do
  subject do
    described_class.new(
      submission: instance_double(Submission,
                                  id: SecureRandom.uuid, data: { court: }, events: events)
    )
  end

  let(:events) { [] }
  let(:court) { 'Acton - C2723' }

  describe '#court_name' do
    it 'returns the court name from list' do
      expect(subject.court_name).to eq('ACTON')
    end

    context 'when court is custom' do
      let(:court) { 'Some custom court - n/a' }

      it 'returns the custom court name without the suffix' do
        expect(subject.court_name).to eq('Some custom court')
      end
    end
  end

  describe '#court_id' do
    it 'returns the court id from list' do
      expect(subject.court_id).to eq('C2723')
    end

    context 'when court is custom' do
      let(:court) { 'Some custom court - n/a' }

      it 'returns the custom court id label' do
        expect(subject.court_id).to eq(I18n.t('laa_crime_forms_common.shared.custom'))
      end
    end
  end

  describe '#original_submission_month' do
    context 'when there is no decision event' do
      let(:events) { [instance_double(Event, event_type: 'Event::NewVersion', created_at: Date.new(2023, 5, 15))] }

      before do
        allow(subject).to receive(:request_type).and_return('non_standard_mag_appeal')
      end

      it 'raises an error' do
        expect { subject.original_submission_month }.to raise_error RuntimeError
      end
    end

    context 'when there is a decision event' do
      let(:events) { [instance_double(Event, event_type: 'Event::Decision', created_at: Date.new(2023, 5, 15))] }

      context 'when request_type is non_standard_mag_appeal' do
        before do
          allow(subject).to receive(:request_type).and_return('non_standard_mag_appeal')
        end

        it 'returns the month of the original submission date' do
          expect(subject.original_submission_month).to eq(5)
        end
      end

      context 'when request_type is not non_standard_magistrate' do
        before do
          allow(subject).to receive(:request_type).and_return('non_standard_magistrate')
        end

        it 'returns the current month' do
          expect(subject.original_submission_month).to eq(Date.current.month)
        end
      end
    end
  end

  describe '#original_submission_year' do
    let(:events) { [instance_double(Event, event_type: 'Event::Decision', created_at: Date.new(2023, 5, 15))] }

    context 'when request_type is non_standard_mag_appeal' do
      before do
        allow(subject).to receive(:request_type).and_return('non_standard_mag_appeal')
      end

      it 'returns the year of the original submission date' do
        expect(subject.original_submission_year).to eq(2023)
      end
    end

    context 'when request_type is not non_standard_magistrate' do
      before do
        allow(subject).to receive(:request_type).and_return('non_standard_magistrate')
      end

      it 'returns the current year' do
        expect(subject.original_submission_year).to eq(Date.current.year)
      end
    end
  end
end
