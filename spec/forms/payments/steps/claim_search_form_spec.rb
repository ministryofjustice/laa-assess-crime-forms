require 'rails_helper'

RSpec.describe Payments::Steps::ClaimSearchForm, type: :model do
  subject(:form) { described_class.new(query:, request_type:) }

  let(:query) { 'LAA-123ABC' }
  let(:request_type) { 'nsm' }

  describe 'validations' do
    context 'when query is present' do
      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when query is blank' do
      let(:query) { nil }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:query]).to include("can't be blank")
      end
    end
  end

  describe '#executed?' do
    it 'returns false when @search_response is nil' do
      expect(form.executed?).to be false
    end

    it 'returns true when @search_response is present' do
      form.instance_variable_set(:@search_response, { some: 'result' })
      expect(form.executed?).to be true
    end
  end

  describe '#conduct_search' do
    let(:client) { instance_double(AppStoreClient) }
    let(:error) { StandardError.new('boom') }

    before do
      allow(AppStoreClient).to receive(:new).and_return(client)
      allow(client).to receive(:search).and_raise(error)
      allow(Sentry).to receive(:capture_exception)
    end

    it 'captures search errors and adds a base validation error' do
      expect(form.conduct_search).to be_nil
      expect(Sentry).to have_received(:capture_exception).with(error)
      expect(form.errors.added?(:base, :search_error)).to be(true)
    end
  end
end
