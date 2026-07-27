require 'rails_helper'

RSpec.describe Payments::ScheduleNsmReports do
  subject { described_class.new }

  let(:current_date) { DateTime.new(2000, 1, 1).strftime('%Y-%m-%d') }
  let(:recipients) { 'finance@example.com,manager@example.com' }
  let(:start_date) { '2000-01-01' }
  let(:dummy) { double(:mailer, deliver_now: true) }

  before do
    allow(Payments::NsmReportMailer).to receive(:notify).with(any_args).and_return(dummy)
    allow(ENV).to receive(:fetch).with('NSM_REPORT_EMAIL_ADDRESSES', nil).and_return(recipients)
    allow(FileUtils).to receive(:rm_rf).and_return(true)
  end

  describe '#perform' do
    it 'sends an email to finance and clears the tmp/uploaded/reports directory' do
      travel_to current_date do
        subject.perform
        expect(Payments::NsmReportMailer).to have_received(:notify).with(start_date, current_date, 'finance@example.com')
        expect(Payments::NsmReportMailer).to have_received(:notify).with(start_date, current_date, 'manager@example.com')
        expect(FileUtils).to have_received(:rm_rf).with(Rails.root.join('tmp/uploaded/reports'))
      end
    end
  end
end
