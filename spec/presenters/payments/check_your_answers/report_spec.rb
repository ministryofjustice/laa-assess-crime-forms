require 'rails_helper'

RSpec.describe Payments::CheckYourAnswers::Report do
  subject(:report) { described_class.new(session_answers, params) }

  let(:params) { { id: '1234' } }

  describe '#cost_summary' do
    context 'when request_type is non_standard_magistrate' do
      let(:session_answers) { { 'request_type' => 'non_standard_magistrate' } }

      context 'when not from an existing digital submission' do
        it 'builds an NSM costs summary' do
          summary = instance_double(Payments::NsmCostsSummary)

          expect(Payments::NsmCostsSummary).to receive(:new).with(session_answers,
                                                                  from_submission: false).and_return(summary)
          expect(report.cost_summary).to eq(summary)
        end
      end

      context 'when from an existing digital submission' do
        let(:params) { { id: '1234', submission: true } }

        it 'builds an NSM costs summary with from_submission set to true' do
          summary = instance_double(Payments::NsmCostsSummary)

          expect(Payments::NsmCostsSummary).to receive(:new).with(session_answers,
                                                                  from_submission: true).and_return(summary)
          expect(report.cost_summary).to eq(summary)
        end
      end
    end

    context 'when request_type is non_standard_mag_amendment' do
      let(:session_answers) { { 'request_type' => 'non_standard_mag_amendment' } }

      it 'builds an amended NSM costs summary' do
        summary = instance_double(Payments::NsmCostsSummaryAmended)

        expect(Payments::NsmCostsSummaryAmended).to receive(:new).with(session_answers).and_return(summary)
        expect(report.cost_summary).to eq(summary)
      end
    end

    context 'when request_type is non_standard_mag_appeal' do
      let(:session_answers) { { 'request_type' => 'non_standard_mag_appeal' } }

      it 'builds an amended NSM costs summary' do
        summary = instance_double(Payments::NsmCostsSummaryAmended)

        expect(Payments::NsmCostsSummaryAmended).to receive(:new).with(session_answers).and_return(summary)
        expect(report.cost_summary).to eq(summary)
      end
    end

    context 'when request_type is non_standard_mag_supplemental' do
      let(:session_answers) { { 'request_type' => 'non_standard_mag_supplemental' } }

      it 'builds an NSM costs summary when no linked claim references are present' do
        summary = instance_double(Payments::NsmCostsSummary)

        expect(Payments::NsmCostsSummary).to receive(:new).with(session_answers).and_return(summary)
        expect(report.cost_summary).to eq(summary)
      end

      context 'when laa_reference is present' do
        let(:session_answers) { { 'request_type' => 'non_standard_mag_supplemental', 'laa_reference' => 'LAA123' } }

        it 'builds an amended and claimed NSM costs summary' do
          summary = instance_double(Payments::NsmCostsSummaryAmendedAndClaimed)

          expect(Payments::NsmCostsSummaryAmendedAndClaimed).to receive(:new).with(session_answers).and_return(summary)
          expect(report.cost_summary).to eq(summary)
        end
      end

      context 'when linked_laa_reference is present' do
        let(:session_answers) { { 'request_type' => 'non_standard_mag_supplemental', 'linked_laa_reference' => 'LAA456' } }

        it 'builds an amended and claimed NSM costs summary' do
          summary = instance_double(Payments::NsmCostsSummaryAmendedAndClaimed)

          expect(Payments::NsmCostsSummaryAmendedAndClaimed).to receive(:new).with(session_answers).and_return(summary)
          expect(report.cost_summary).to eq(summary)
        end
      end
    end
  end
end
