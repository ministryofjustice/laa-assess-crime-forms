require 'rails_helper'

RSpec.describe Payments::ScheduleReportBase do
  subject { described_class.new }

  describe '#perform' do
    context 'when the payments feature flag is enabled' do
      before do
        allow(FeatureFlags).to receive_message_chain(:payments, :enabled?).and_return(true)
        allow(subject).to receive_messages(recipients: ['test@example.com'], start_date: '2023-01-01', end_date: '2023-01-31',
                                           report_type: 'nsm')
        allow(Payments::EmailPaymentReportMailer).to receive_message_chain(:notify, :deliver_now).and_return(true)
      end

      it 'sends an email to all the recipients' do
        expect(Payments::EmailPaymentReportMailer).to receive(:notify)
          .with('nsm', '2023-01-01', '2023-01-31', 'test@example.com')
        subject.perform
      end
    end

    context 'when the payments feature flag is disabled' do
      before do
        allow(FeatureFlags).to receive_message_chain(:payments, :enabled?).and_return(false)
      end

      it 'does not send any emails' do
        expect(Payments::EmailPaymentReportMailer).not_to receive(:notify)
        subject.perform
      end
    end
  end

  describe '#recipient_key' do
    it 'raises NotImplementedError' do
      expect { subject.recipient_key }.to raise_error(NotImplementedError)
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
