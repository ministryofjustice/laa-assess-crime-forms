require 'rails_helper'

RSpec.describe Payments::CostSummaryService do
  describe '#call' do
    subject(:service) { described_class.new(session_answers, to_be_paid, from_submission) }

    let(:session_answers) do
      {
        'request_type' => request_type,
        'laa_reference' => laa_reference
      }
    end
    let(:to_be_paid) { false }
    let(:laa_reference) { nil }
    let(:request_type) { nil }
    let(:from_submission) { false }

    context 'when cost summary is for to be paid costs' do
      let(:to_be_paid) { true }

      context 'when the request is for an additional non_standard_magistrate payment' do
        let(:request_type) { 'non_standard_mag_supplemental' }

        it 'returns the appropriate cost summary object' do
          expect(service.call).to be_a(Payments::NsmCostsSummaryToBePaid)
        end
      end

      context 'when the request is for an additional assigned counsel payment' do
        let(:request_type) { 'assigned_counsel_appeal' }

        it 'returns the appropriate cost summary object' do
          expect(service.call).to be_a(Payments::AcCostsSummaryToBePaid)
        end
      end
    end

    context 'when cost summary is not for to be paid costs' do
      let(:to_be_paid) { false }

      context 'when request type is assigned counsel' do
        let(:request_type) { 'assigned_counsel' }

        it 'returns the appropriate cost summary object' do
          expect(service.call).to be_a(Payments::AcCostsSummary)
        end
      end

      context 'when request type is assigned counsel appeal' do
        let(:request_type) { 'assigned_counsel_appeal' }

        it 'returns the appropriate cost summary object' do
          expect(service.call).to be_a(Payments::AcCostsSummaryAppealed)
        end
      end

      context 'when request type is assigned counsel amendment' do
        let(:request_type) { 'assigned_counsel_amendment' }

        it 'returns the appropriate cost summary object' do
          expect(service.call).to be_a(Payments::AcCostsSummaryAmended)
        end
      end

      context 'when request type is non standard magistrate' do
        let(:request_type) { 'non_standard_magistrate' }

        it 'returns the appropriate cost summary object' do
          expect(service.call).to be_a(Payments::NsmCostsSummary)
        end
      end

      context 'when request type is breach of injunction' do
        let(:request_type) { 'breach_of_injunction' }

        it 'returns the appropriate cost summary object' do
          expect(service.call).to be_a(Payments::NsmCostsSummary)
        end
      end

      context 'when request type is non standard magistrate amendment' do
        let(:request_type) { 'non_standard_mag_amendment' }

        it 'returns the appropriate cost summary object' do
          expect(service.call).to be_a(Payments::NsmCostsSummaryAmended)
        end
      end

      context 'when request type is non standard magistrate appeal' do
        let(:request_type) { 'non_standard_mag_appeal' }

        it 'returns the appropriate cost summary object' do
          expect(service.call).to be_a(Payments::NsmCostsSummaryAmended)
        end
      end

      context 'when request type is non standard magistrate supplemental' do
        let(:request_type) { 'non_standard_mag_supplemental' }

        context 'when the request is linked to an existing claim' do
          let(:laa_reference) { 'some_reference' }

          it 'returns the appropriate cost summary object' do
            expect(service.call).to be_a(Payments::NsmCostsSummaryAmendedAndClaimed)
          end
        end

        context 'when the request is not linked to an existing claim' do
          let(:laa_reference) { nil }

          it 'returns the appropriate cost summary object' do
            expect(service.call).to be_a(Payments::NsmCostsSummary)
          end
        end
      end
    end
  end
end
