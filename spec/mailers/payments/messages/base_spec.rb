# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payments::Messages::Base do
  subject { described_class.new(start_date, end_date) }

  let(:start_date) { '2023-01-01' }
  let(:end_date) { '2023-01-31' }

  describe '#template' do
    it 'throws a not implemented exception' do
      expect { subject.template }.to raise_error(NotImplementedError)
    end
  end

  describe '#report_name' do
    it 'throws a not implemented exception' do
      expect { subject.report_name }.to raise_error(NotImplementedError)
    end
  end

  describe '#metabase_question_id' do
    it 'raises a not implemented exception' do
      expect { subject.metabase_question_id }.to raise_error(NotImplementedError)
    end
  end

  context 'when start_date or end_date is invalid' do
    it 'raises an error' do
      expect do
        described_class.new('invalid_date',
                            end_date)
      end.to raise_error(RuntimeError, 'start_date and end_date must be valid dates in YYYY-MM-DD format')
      expect do
        described_class.new(start_date,
                            'invalid_date')
      end.to raise_error(RuntimeError, 'start_date and end_date must be valid dates in YYYY-MM-DD format')
    end
  end
end
