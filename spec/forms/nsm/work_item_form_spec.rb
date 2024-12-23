require 'rails_helper'

RSpec.describe Nsm::WorkItemForm do
  subject { described_class.new(params) }

  let(:claim) { build(:claim) }
  let(:params) do
    { claim:, id:, time_spent:, uplift:, item:, explanation:, current_user:, work_type_value:,
      work_item_pricing:, }
  end
  let(:id) { 'cf5e303e-98dd-4b0f-97ea-3560c4c5f137' }
  let(:time_spent) { 95 }
  let(:uplift) { 'yes' }
  let(:item) do
    instance_double(
      Nsm::V1::WorkItem,
      id: id,
      time_spent: 161,
      uplift: uplift_provided ? 95 : nil,
      original_uplift: original_uplift,
      uplift?: uplift_provided,
      work_type: TranslationObject.new('waiting', 'nsm.work_type')
    )
  end
  let(:uplift_provided) { !original_uplift.nil? }
  let(:original_uplift) { 95 }
  let(:explanation) { 'change to work items' }
  let(:current_user) { instance_double(User) }
  let(:work_type_value) { 'waiting' }
  let(:work_item_pricing) { { 'waiting' => 12.5, 'travel' => 4.7 } }
  let(:app_store_client) { instance_double(AppStoreClient, create_events: true) }

  before { allow(AppStoreClient).to receive(:new).and_return(app_store_client) }

  describe '#validations' do
    context 'uplift' do
      %w[yes no].each do |uplift_value|
        context 'when it is valid' do
          let(:uplift) { uplift_value }

          it { expect(subject).to be_valid }
        end
      end

      context 'when it is something else' do
        let(:uplift) { 'other' }

        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:uplift, :inclusion)).to be(true)
        end
      end
    end

    context 'explanation' do
      context 'when it is blank' do
        let(:explanation) { '' }

        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:explanation, :blank)).to be(true)
        end
      end
    end

    context 'when data has not changed' do
      let(:time_spent) { 161 }
      let(:uplift) { 'no' }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:base, :no_change)).to be(true)
      end

      context 'when there was no uplift originally' do
        let(:original_uplift) { nil }

        it 'marks the error on the base' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:base, :no_change)).to be(true)
        end
      end

      context 'and explanation would otherwise have an error' do
        let(:explanation) { '' }

        it 'ignores the explanation error' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:explanation, :blank)).to be(false)
        end
      end

      context 'but the explanation has' do
        before do
          work_item = claim.data['work_items'].detect { _1['id'] == id }
          work_item['adjustment_comment'] = 'Previous explanation'
        end

        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end

  describe '#uplift' do
    it 'can be set with a string' do
      expect(described_class.new(uplift: 'yes').uplift).to eq('yes')
      expect(described_class.new(uplift: 'no').uplift).to eq('no')
    end

    it 'can be set with an integer' do
      expect(described_class.new(uplift: 0).uplift).to eq('yes')
      expect(described_class.new(uplift: 95).uplift).to eq('no')
    end

    it 'not set when nil' do
      expect(described_class.new(uplift: nil).uplift).to be_nil
    end
  end

  describe '#save' do
    let(:current_user) { create(:caseworker) }

    context 'when record is invalid' do
      let(:uplift) { nil }

      it { expect(subject.save).to be_falsey }
    end

    context 'when only uplift has changed' do
      let(:uplift) { 'yes' }
      let(:time_spent) { nil }

      it 'updates the JSON data' do
        subject.save
        work_item = claim.data['work_items']
                         .detect { |row| row['work_type'] == 'waiting' }
        expect(work_item).to eq(
          'id' => 'cf5e303e-98dd-4b0f-97ea-3560c4c5f137',
          'time_spent' => 161,
          'pricing' => 24.0,
          'work_type' => 'waiting',
          'uplift' => 0,
          'uplift_original' => 95,
          'fee_earner' => 'aaa',
          'completed_on' => '2022-12-12',
          'adjustment_comment' => 'change to work items',
          'position' => 1
        )
      end
    end

    context 'when only time_spent has changed' do
      let(:uplift) { 'no' }

      it 'updates the JSON data' do
        subject.save
        work_item = claim.data['work_items']
                         .detect { |row| row['work_type'] == 'waiting' }
        expect(work_item).to eq(
          'id' => 'cf5e303e-98dd-4b0f-97ea-3560c4c5f137',
          'time_spent' => 95,
          'time_spent_original' => 161,
          'pricing' => 24.0,
          'work_type' => 'waiting',
          'uplift' => 95,
          'fee_earner' => 'aaa',
          'completed_on' => '2022-12-12',
          'adjustment_comment' => 'change to work items',
          'position' => 1,
        )
      end

      context 'when uplift is not populated from provider' do
        let(:original_uplift) { nil }

        it 'saves without error' do
          expect { subject.save }.not_to raise_error
        end
      end
    end

    context 'when only explanation has changed' do
      let(:uplift) { 'no' }
      let(:time_spent) { 161 }

      before do
        work_item = claim.data['work_items'].detect { _1['id'] == id }
        work_item['adjustment_comment'] = 'Previous explanation'
      end

      it 'updates the JSON data' do
        subject.save
        work_item = claim.data['work_items']
                         .detect { |row| row['work_type'] == 'waiting' }
        expect(work_item).to eq(
          'id' => 'cf5e303e-98dd-4b0f-97ea-3560c4c5f137',
          'time_spent' => 161,
          'pricing' => 24.0,
          'work_type' => 'waiting',
          'uplift' => 95,
          'fee_earner' => 'aaa',
          'completed_on' => '2022-12-12',
          'adjustment_comment' => 'change to work items',
          'position' => 1,
        )
      end
    end

    context 'when claim has legacy translations and work type value has changed' do
      let(:claim) { build :claim, data: }
      let(:data) { build(:nsm_data, :legacy_translations) }
      let(:work_type_value) { 'travel' }

      it 'updates the JSON data' do
        subject.save
        work_item = claim.data['work_items'].detect { |row| row['work_type'] == 'travel' }
        expect(work_item).to eq(
          'id' => 'cf5e303e-98dd-4b0f-97ea-3560c4c5f137',
          'time_spent' => 95,
          'time_spent_original' => 161,
          'pricing' => 24.0,
          'work_type' => 'travel',
          'work_type_original' => { 'en' => 'Waiting', 'value' => 'waiting' },
          'uplift' => 0,
          'uplift_original' => 95,
          'fee_earner' => 'aaa',
          'completed_on' => '2022-12-12',
          'adjustment_comment' => 'change to work items',
        )
      end
    end
  end
end
