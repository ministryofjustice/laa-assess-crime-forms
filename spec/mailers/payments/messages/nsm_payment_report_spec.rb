require 'rails_helper'

RSpec.describe Payments::Messages::NsmPaymentReport do
  subject { described_class.new(start_date, end_date) }

  let(:start_date) { '2023-01-01' }
  let(:end_date) { '2023-01-31' }
  let(:template_id) { '29db3a67-a5c0-454c-bdc4-0a8b0b9958a8' }
  let(:report_name) { 'nsm_payment_report' }
  let(:report_id) { '2' }
  let(:attach_link) { 'https://example.com/uploaded_file.csv' }

  before do
    allow(MetabaseApiClient).to receive(:new).and_return(double(download_question: 'csv_data'))
    allow(ENV).to receive(:fetch).with('METABASE_NSM_PAYMENT_DASHBOARD_ID', nil).and_return(report_id)
    allow(Notifications).to receive(:prepare_upload).with(any_args).and_return(attach_link)
  end

  describe '#contents' do
    context 'when the report file does not exist' do
      it 'prepares the file and generates the correct content hash' do
        expect(File).to receive(:exist?).and_return(false)
        expect(subject.contents).to eq({
                                         start_date: start_date,
                                         end_date: end_date,
                                         link_to_file: attach_link
                                       })
      end
    end

    context 'when the report file already exists' do
      it 'does not prepare the file again and generates the correct content hash' do
        expect(File).to receive(:exist?).and_return(true)
        expect(MetabaseApiClient).not_to receive(:new)
        expect(subject.contents).to eq({
                                         start_date: start_date,
                                         end_date: end_date,
                                         link_to_file: attach_link
                                       })
      end
    end
  end
end
