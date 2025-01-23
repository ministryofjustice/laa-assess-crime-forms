require 'rails_helper'

RSpec.describe BaseParamValidator, type: :model do
  subject { described_class.new }

  let(:errors) do
    {
      title: ['Must be populated'],
      cost: ['Must be positive', 'Must be an integer']
    }
  end

  before do
    allow(subject).to receive_message_chain(:errors, :messages).and_return(errors)
  end

  describe '#error_summary' do
    it 'correctly summarises errors' do
      expect(subject.error_summary).to eq(
        "Field: title, Errors: [\"Must be populated\"]\n" \
        'Field: cost, Errors: ["Must be positive", "Must be an integer"]'
      )
    end
  end
end
