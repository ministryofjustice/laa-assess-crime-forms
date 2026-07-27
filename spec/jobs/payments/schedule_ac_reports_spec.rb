require 'rails_helper'

RSpec.describe Payments::ScheduleAcReports do
  subject { described_class.new }

  let(:current_date) { DateTime.new(2026, 8, 30) }
  let(:recipients) { 'finance@example.com,manager@example.com' }
  let(:start_date) { (current_date - 15).strftime('%Y-%m-%d') }
  let(:end_date) { (current_date - 1).strftime('%Y-%m-%d') }
  let(:dummy) { double(:mailer, deliver_now: true) }

  before do
    allow(Payments::EmailPaymentReportMailer).to receive(:notify).with(any_args).and_return(dummy)
    allow(ENV).to receive(:fetch).with('AC_REPORT_EMAIL_ADDRESSES', nil).and_return(recipients)
    allow(FileUtils).to receive(:rm_rf).and_return(true)
  end

  describe '#perform' do
    it 'sends an email to finance and clears the tmp/uploaded/reports directory' do
      travel_to current_date do
        subject.perform
        expect(Payments::EmailPaymentReportMailer).to have_received(:notify).with('ac', start_date, end_date,
                                                                                  'finance@example.com')
        expect(Payments::EmailPaymentReportMailer).to have_received(:notify).with('ac', start_date, end_date,
                                                                                  'manager@example.com')
        expect(FileUtils).to have_received(:rm_rf).with(Rails.root.join('tmp/uploaded/reports'))
      end
    end
  end
end
