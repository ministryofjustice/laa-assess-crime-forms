require 'rails_helper'
require 'fileutils'

RSpec.describe Payments::Messages::AcPaymentReport do
  subject { described_class.new(start_date, end_date) }

  let(:start_date) { '2023-01-01' }
  let(:end_date) { '2023-01-31' }
  let(:report_id) { '2' }
  let(:attach_link) { 'https://example.com/uploaded_file.csv' }
  let(:filename) { "ac_payment_report_#{start_date}_to_#{end_date}.csv" }
  let(:file_path) { Rails.root.join('tmp/uploaded/reports', filename).to_s }

  before do
    allow(MetabaseApiClient).to receive(:new).and_return(double(download_question: 'csv_data'))
    allow(ENV).to receive(:fetch).with('METABASE_AC_PAYMENT_DASHBOARD_ID', nil).and_return(report_id)
    allow(Notifications).to receive(:prepare_upload)
      .with(instance_of(File), filename: filename, retention_period: '1 week')
      .and_return(attach_link)
  end

  after do
    FileUtils.rm_f(file_path)
  end

  describe '#contents' do
    context 'when the report file does not exist' do
      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:binwrite).and_call_original
      end

      it 'prepares the file and generates the correct content hash' do
        expect(subject.contents).to eq({
                                         start_date: start_date,
                                         end_date: end_date,
                                         link_to_file: attach_link
                                       })
      end

      it 'creates the report file with the correct content' do
        expect(File).to receive(:binwrite).with(file_path, 'csv_data')
        subject.contents
      end
    end

    context 'when the report file already exists' do
      before do
        FileUtils.mkdir_p(File.dirname(file_path))
        File.binwrite(file_path, 'existing_csv_data')
      end

      it 'does not prepare the file again and generates the correct content hash' do
        expect(MetabaseApiClient).not_to receive(:new)
        expect(File).not_to receive(:binwrite).with(file_path, 'csv_data')
        expect(subject.contents).to eq({
                                         start_date: start_date,
                                         end_date: end_date,
                                         link_to_file: attach_link
                                       })
      end
    end
  end
end
