require 'rails_helper'
require 'fileutils'

RSpec.shared_examples 'create a payment report' do |report_type|
  subject { described_class.new(start_date, end_date) }

  let(:start_date) { '2026-01-01' }
  let(:end_date) { '2026-01-31' }
  let(:report_id) { '2' }
  let(:attach_link) { 'https://example.com/uploaded_file.csv' }
  let(:file_prefix) { "#{report_type}_payment_report" }
  let(:filename) { "#{file_prefix}_2026-01-01.csv" }
  let(:file_path) { Rails.root.join('tmp/uploaded/reports', filename).to_s }
  let(:template_id) { 'template_id' }
  let(:current_date) { DateTime.new(2026, 1, 1) }

  before do
    if report_type == 'ac'
      allow(ENV).to receive(:fetch).with('AC_REPORT_EMAIL_TEMPLATE_ID', nil).and_return(template_id)
      allow(ENV).to receive(:fetch).with('METABASE_AC_PAYMENT_DASHBOARD_ID', nil).and_return(report_id)
    elsif report_type == 'nsm'
      allow(ENV).to receive(:fetch).with('NSM_REPORT_EMAIL_TEMPLATE_ID', nil).and_return(template_id)
      allow(ENV).to receive(:fetch).with('METABASE_NSM_PAYMENT_DASHBOARD_ID', nil).and_return(report_id)
    end
    allow(MetabaseApiClient).to receive(:new).and_return(double(download_question: 'csv_data'))
    allow(Notifications).to receive(:prepare_upload).and_return(attach_link)
  end

  after do
    FileUtils.rm_f(file_path)
  end

  describe '#template' do
    it 'returns the correct template ID' do
      expect(subject.template).to eq(template_id)
    end
  end

  describe '#contents' do
    context 'when the report file does not exist' do
      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:binwrite).and_call_original
      end

      it 'prepares the file and generates the correct content hash' do
        travel_to(current_date) do
          expect(subject.contents).to eq({
                                           report_date: '1 January 2026',
                                          start_date: '1 January 2026',
                                          end_date: '31 January 2026',
                                          link_to_file: attach_link
                                         })
        end
      end

      it 'creates the report file with the correct content' do
        travel_to(current_date) do
          expect(File).to receive(:binwrite).with(file_path, 'csv_data')
          subject.contents
        end
      end
    end

    context 'when the report file already exists' do
      before do
        FileUtils.mkdir_p(File.dirname(file_path))
        File.binwrite(file_path, 'existing_csv_data')
      end

      it 'does not prepare the file again and generates the correct content hash' do
        travel_to(current_date) do
          expect(MetabaseApiClient).not_to receive(:new)
          expect(File).not_to receive(:binwrite).with(file_path, 'csv_data')
          expect(subject.contents).to eq({
                                           report_date: '1 January 2026',
                                          start_date: '1 January 2026',
                                          end_date: '31 January 2026',
                                          link_to_file: attach_link
                                         })
        end
      end
    end
  end
end
