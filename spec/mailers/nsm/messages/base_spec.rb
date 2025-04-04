# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nsm::Messages::Base do
  subject(:feedback) { described_class.new(claim) }

  let(:claim) { build(:claim, data:) }
  let(:data) { build(:nsm_data, solicitor: { 'contact_email' => 'provider@example.com' }) }

  describe '#template' do
    it 'throws a not implemented exception' do
      expect { subject.template }.to raise_error(NotImplementedError)
    end
  end

  describe '#contents' do
    it 'throws a not implemented exception' do
      expect { subject.contents }.to raise_error(NotImplementedError)
    end
  end

  describe '#recipient' do
    it 'uses the provider email address' do
      expect(subject.recipient).to eq 'provider@example.com'
    end

    context 'when there is an alternative contact email' do
      before do
        claim.data['solicitor']['contact_email'] = 'alt@example.com'
      end

      it 'uses the alternative contact' do
        expect(subject.recipient).to eq 'alt@example.com'
      end
    end
  end
end
