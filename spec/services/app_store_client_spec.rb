require 'rails_helper'

RSpec.describe AppStoreClient, :stub_oauth_token do
  let(:response) { double(:response, code:, body:) }
  let(:code) { 200 }
  let(:body) { { some: :data }.to_json }
  let(:username) { nil }
  let(:claim) { instance_double(Claim, id: SecureRandom.uuid) }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(described_class).to receive(:get)
      .and_return(response)
  end

  describe '#update_submission' do
    let(:application_id) { SecureRandom.uuid }
    let(:message) { { application_id: } }
    let(:response) { double(:response, code: code, body: '') }
    let(:code) { 201 }
    let(:username) { nil }

    before do
      allow(described_class).to receive(:put)
        .and_return(response)
    end

    context 'when APP_STORE_URL is present' do
      before do
        allow(ENV).to receive(:fetch).with('APP_STORE_URL', 'http://localhost:8000')
                                     .and_return('http://some.url')
      end

      it 'puts the message to the specified URL' do
        expect(described_class).to receive(:put).with("http://some.url/v1/application/#{application_id}",
                                                      body: message.to_json,
                                                      headers: { authorization: 'Bearer test-bearer-token' })

        subject.update_submission(message)
      end

      context 'when authentication is not configured' do
        before do
          allow(ENV).to receive(:fetch).with('APP_STORE_TENANT_ID', nil).and_return(nil)
        end

        it 'puts the message without headers' do
          expect(described_class).to receive(:put).with("http://some.url/v1/application/#{application_id}",
                                                        body: message.to_json,
                                                        headers: { 'X-Client-Type': 'caseworker' })

          subject.update_submission(message)
        end
      end
    end

    context 'when APP_STORE_URL is not present' do
      it 'puts the message to default localhost url' do
        expect(described_class).to receive(:put).with("https://appstore.example.com/v1/application/#{application_id}",
                                                      body: message.to_json,
                                                      headers: { authorization: 'Bearer test-bearer-token' })

        subject.update_submission(message)
      end
    end

    context 'when response code is 201 - created' do
      it 'returns a created status' do
        expect(subject.update_submission(message)).to eq(:success)
      end
    end

    context 'when response code is 409 - conflict' do
      let(:code) { 409 }

      it 'returns a warning status' do
        expect(subject.update_submission(message)).to eq(:warning)
      end

      it 'sends a Sentry message' do
        expect(Sentry).to receive(:capture_message).with(
          "Application ID already exists in AppStore for '#{application_id}'"
        )

        subject.update_submission(message)
      end
    end

    context 'when response code is unexpected (neither 201 or 209)' do
      let(:code) { 501 }

      it 'raises and error' do
        expect { subject.update_submission(message) }.to raise_error(
          "Unexpected response from AppStore - status 501 for '#{application_id}'"
        )
      end
    end
  end

  describe '#create_events' do
    let(:application_id) { SecureRandom.uuid }
    let(:message) { [{ event: :data }] }
    let(:response) { double(:response, code:) }
    let(:code) { 201 }
    let(:username) { nil }

    before do
      allow(described_class).to receive(:post).and_return(response)
    end

    it 'puts the message to default localhost url' do
      expect(described_class).to receive(:post).with("https://appstore.example.com/v1/submissions/#{application_id}/events",
                                                     body: message.to_json,
                                                     headers: { authorization: 'Bearer test-bearer-token' })

      subject.create_events(application_id, message)
    end

    context 'when response code is 201 - created' do
      it 'returns a created status' do
        expect(subject.create_events(application_id, message)).to eq(:success)
      end
    end

    context 'when response code is unexpected (neither 200 or 201)' do
      let(:code) { 501 }

      it 'raises an error' do
        expect { subject.create_events(application_id, message) }.to raise_error(
          'Unexpected response from AppStore - status 501 on create events'
        )
      end
    end
  end

  describe '#search' do
    let(:code) { 201 }

    before do
      allow(ENV).to receive(:fetch).with('APP_STORE_URL', 'http://localhost:8000')
                                   .and_return('http://some.url')
      allow(described_class).to receive(:post)
        .and_return(response)
    end

    it 'delegates search context to submissions' do
      expect(described_class).to receive(:post).with('http://some.url/v1/submissions/searches',
                                                     headers: { authorization: 'Bearer test-bearer-token' })
      subject.search(nil, :submissions)
    end

    it 'delegates search context to payments' do
      expect(described_class).to receive(:post).with('http://some.url/v1/payment_requests/searches',
                                                     headers: { authorization: 'Bearer test-bearer-token' })
      subject.search(nil, :payment_requests)
    end
  end
end
