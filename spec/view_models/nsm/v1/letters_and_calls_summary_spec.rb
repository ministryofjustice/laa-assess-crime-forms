require 'rails_helper'

RSpec.describe Nsm::V1::LettersAndCallsSummary, type: :model do
  subject { described_class.new(submission:) }

  let(:letters_and_calls) do
    [{ 'type' => 'letters', 'count' => 12, 'uplift' => uplift, 'pricing' => 3.56 }]
  end
  let(:uplift) { 0 }
  let(:submission) { build(:claim).tap { |claim| claim.data.merge!('letters_and_calls' => letters_and_calls) } }

  describe 'uplift?' do
    context 'when uplift is 0' do
      it { expect(subject).not_to be_uplift }
    end

    context 'when uplift is positive' do
      let(:uplift) { 100 }

      it { expect(subject).to be_uplift }
    end

    context 'when uplift is nil' do
      let(:uplift) { nil }

      it { expect(subject).not_to be_uplift }
    end
  end
end
