require 'rails_helper'

RSpec.describe Nsm::V1::PaymentClaimDetails do
  subject do
    described_class.new(
      submission: instance_double(Submission,
                                  data: { court: })
    )
  end

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
end
