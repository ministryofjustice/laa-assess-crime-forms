require 'rails_helper'

describe HostEnv do
  context 'when local development rails environment' do
    before do
      allow(Rails.env).to receive(:development?).and_return(true)
    end

    describe 'HostEnv.uat?' do
      it 'returns false' do
        expect(described_class.uat?).to be false
      end
    end

    describe 'HostEnv.production?' do
      it 'returns false' do
        expect(described_class.production?).to be false
      end
    end

    describe '.local?' do
      it 'returns true' do
        expect(described_class.local?).to be true
      end
    end
  end

  context 'when local test rails environment' do
    describe 'HostEnv.uat?' do
      it 'returns false' do
        expect(described_class.uat?).to be false
      end
    end

    describe '.production?' do
      it 'returns true' do
        expect(described_class.production?).to be false
      end
    end

    describe '.local?' do
      it 'returns true' do
        expect(described_class.local?).to be true
      end
    end
  end

  describe 'ENV variable is set in production envs' do
    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      allow(ENV).to receive(:fetch).with('ENV').and_return(env_name)
    end

    context 'when uat host' do
      let(:env_name) { HostEnv::UAT }

      it { expect(described_class.local?).to be(false) }
      it { expect(described_class.uat?).to be(true) }
      it { expect(described_class.production?).to be(false) }
    end

    context 'when production host' do
      let(:env_name) { HostEnv::PRODUCTION }

      it { expect(described_class.local?).to be(false) }
      it { expect(described_class.uat?).to be(false) }
      it { expect(described_class.production?).to be(true) }
    end

    context 'when unknown host' do
      let(:env_name) { 'foobar' }

      it { expect(described_class.local?).to be(false) }
      it { expect(described_class.uat?).to be(false) }
      it { expect(described_class.production?).to be(false) }
    end
  end

  describe 'when is a production env and the ENV variable is not set' do
    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
    end

    it 'raises an exception so we are fully aware' do
      expect do
        described_class.production?
      end.to raise_exception(KeyError)
    end
  end
end
