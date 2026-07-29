require 'rails_helper'

RSpec.describe Payments::ScheduleNsmReports do
  subject { described_class.new }

  let(:current_date) { DateTime.new(2000, 1, 1).strftime('%Y-%m-%d') }
  let(:recipients) { 'finance@example.com,manager@example.com' }
  let(:start_date) { '2000-01-01' }
  let(:dummy) { double(:mailer, deliver_now: true) }

  before do
    allow(Payments::EmailPaymentReportMailer).to receive(:notify).with(any_args).and_return(dummy)
    allow(ENV).to receive(:fetch).with('NSM_REPORT_EMAIL_ADDRESSES', '').and_return(recipients)
    allow(FileUtils).to receive(:rm_rf).and_return(true)
    allow(FeatureFlags).to receive_message_chain(:payments, :enabled?).and_return(true)
  end

  describe '#perform' do
    it 'sends an email to finance and clears the tmp/uploaded/reports directory' do
      travel_to DateTime.parse(current_date) do
        subject.perform
        expect(Payments::EmailPaymentReportMailer).to have_received(:notify).with('nsm', start_date, current_date,
                                                                                  'finance@example.com')
        expect(Payments::EmailPaymentReportMailer).to have_received(:notify).with('nsm', start_date, current_date,
                                                                                  'manager@example.com')
        expect(FileUtils).to have_received(:rm_rf).with(Rails.root.join('tmp/uploaded/reports'))
      end
    end
  end
end
