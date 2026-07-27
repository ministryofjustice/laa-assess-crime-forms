require 'rails_helper'

RSpec.describe Payments::ScheduleReportBase do
  subject { described_class.new }

  describe '#recipients' do
    it 'raises NotImplementedError' do
      expect { subject.recipients }.to raise_error(NotImplementedError)
    end
  end

  describe '#start_date' do
    it 'raises NotImplementedError' do
      expect { subject.start_date }.to raise_error(NotImplementedError)
    end
  end

  describe '#end_date' do
    it 'raises NotImplementedError' do
      expect { subject.end_date }.to raise_error(NotImplementedError)
    end
  end

  describe '#report_type' do
    it 'raises NotImplementedError' do
      expect { subject.report_type }.to raise_error(NotImplementedError)
    end
  end
end
