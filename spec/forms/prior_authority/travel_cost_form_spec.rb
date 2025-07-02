require 'rails_helper'

RSpec.describe PriorAuthority::TravelCostForm do
  subject { described_class.new(params) }

  let(:primary_quote) { build(:primary_quote, :no_travel, id: 'primary') }
  let(:alternative_quote) { build(:alternative_quote, id: 'alt-1') }
  let(:data) do
    build(:prior_authority_data, quotes: [
            primary_quote,
            alternative_quote
          ])
  end
  let(:submission) { build(:prior_authority_application, data:) }
  let(:all_travel_costs) { BaseViewModel.build(:travel_cost, submission, 'quotes') }
  let(:item) { all_travel_costs.detect(&:primary) }
  let(:travel_time) { 1 }
  let(:travel_cost_per_hour) { 1 }

  describe '#save', :stub_oauth_token do
    let(:params) do
      {
        submission: submission,
        item: item,
        travel_time: travel_time,
        travel_cost_per_hour: travel_cost_per_hour,
        explanation: 'asdf',
        id: submission.id,
      }
    end
    let(:current_user) { create(:caseworker) }
    let(:primary) { submission.data['quotes'].detect { |q| q['id'] == 'primary' } }

    before do
      stub_request(:put, "https://appstore.example.com/v1/application/#{submission.id}").to_return(status: 201)
      subject.save
    end

    context 'adjusted but originally nil' do
      let(:primary_quote) { build(:primary_quote, :with_adjusted_nil_travel, id: 'primary') }

      it 'travel_time_original does not change' do
        expect(primary['travel_time_original']).to be_nil
      end

      it 'travel_time does not change' do
        expect(primary['travel_time']).to eq(1)
      end
    end

    context 'adjust primary travel cost' do
      let(:primary_quote) { build(:primary_quote, id: 'primary') }

      it 'travel_time_original does not change' do
        expect(primary['travel_time_original']).to eq(180)
      end

      it 'travel_time changes' do
        expect(primary['travel_time']).to eq(1)
      end
    end

    context 'adjusted' do
      let(:primary_quote) { build(:primary_quote, :with_adjusted_travel, id: 'primary') }
      let(:travel_time) { 3 }

      it 'travel_time_original does not change' do
        expect(primary['travel_time_original']).to eq(1)
      end

      it 'travel_time does not change' do
        expect(primary['travel_time']).to eq(3)
      end
    end

    context 'adjust when no travel_cost present' do
      it 'adjusts travel_time' do
        expect(primary['travel_time']).to eq(1)
      end

      it 'creates travel_time_original' do
        expect(primary['travel_time_original']).to be_nil
      end

      it 'adjusts travel_cost_per_hour' do
        expect(primary['travel_cost_per_hour']).to eq('1.0')
      end

      it 'creates travel_cost_per_hour_original' do
        expect(primary['travel_cost_per_hour_original']).to be_nil
      end
    end
  end
end
