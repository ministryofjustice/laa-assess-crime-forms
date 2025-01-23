require 'rails_helper'

RSpec.describe PriorAuthority::DownloadsController, type: :controller do
  let(:user) { create :caseworker }
  let(:document) { double(:document, id:, file_name:) }
  let(:id) { '123456789' }

  before do
    allow(LaaCrimeFormsCommon::S3Files).to receive(:temporary_download_url).and_return('www.url.com')
  end

  describe 'show' do
    it 'raises error if file_name not present' do
      expect { get :show, params: { id: id, file_name: nil } }.to raise_error RuntimeError
    end
  end
end
