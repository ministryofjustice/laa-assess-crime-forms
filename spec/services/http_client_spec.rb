require 'rails_helper'

RSpec.describe HttpClient do
  subject { described_class.new }

  describe '#headers' do
    it 'raises NotImplementedError' do
      expect { subject.headers }.to raise_error(NotImplementedError, "#{described_class} has not implemented method 'headers'")
    end
  end

  describe '#host' do
    it 'raises NotImplementedError' do
      expect { subject.host }.to raise_error(NotImplementedError, "#{described_class} has not implemented method 'host'")
    end
  end
end
