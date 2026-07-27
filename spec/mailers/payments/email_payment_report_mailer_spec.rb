# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payments::EmailPaymentReportMailer, type: :mailer do
  subject { described_class.notify(claim_type, start_date, end_date, recipient) }

  let(:start_date) { '2023-01-01' }
  let(:end_date) { '2023-01-31' }
  let(:recipient) { 'test@example.com' }
  let(:claim_type) { nil }
  let(:message_double) { double(template: 'template_id', contents: { start_date: start_date, end_date: end_date, link_to_file: 'https://example.com/uploaded_file.csv' }) }

  context 'when claim_type is ac' do
    let(:claim_type) { 'ac' }

    before do
      allow(Payments::Messages::AcPaymentReport).to receive(:new).with(start_date, end_date).and_return(message_double)
    end

    it 'instantiates the correct message class and sends the email' do
      expect(Payments::Messages::AcPaymentReport).to receive(:new).with(start_date, end_date)
      expect(subject.to).to eq([recipient])
    end
  end

  context 'when claim_type is nsm' do
    let(:claim_type) { 'nsm' }

    before do
      allow(Payments::Messages::NsmPaymentReport).to receive(:new).with(start_date, end_date).and_return(message_double)
    end

    it 'instantiates the correct message class and sends the email' do
      expect(Payments::Messages::NsmPaymentReport).to receive(:new).with(start_date, end_date)
      expect(subject.to).to eq([recipient])
    end
  end
end
