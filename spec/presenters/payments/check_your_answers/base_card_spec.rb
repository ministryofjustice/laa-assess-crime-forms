require 'rails_helper'

RSpec.describe Payments::CheckYourAnswers::BaseCard do
  describe '#change_link_query_params' do
    it 'defaults to no extra query params' do
      expect(described_class.new.change_link_query_params).to eq({})
    end
  end
end
