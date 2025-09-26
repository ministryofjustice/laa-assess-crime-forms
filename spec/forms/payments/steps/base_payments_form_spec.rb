# spec/forms/payments/steps/base_payments_form_spec.rb
require 'rails_helper'

RSpec.describe Payments::Steps::BasePaymentsForm do
  describe '.build' do
    let(:favourite_meal_form) do
      Class.new(described_class) do
        attribute :favourite_meal, :string
      end
    end

    before do
      stub_const('FavouriteMealForm', favourite_meal_form)
    end

    context 'when missing the required multi_step_form_session keyword' do
      it 'raises an ArgumentError' do
        expect do
          FavouriteMealForm.build({})
        end.to raise_error(ArgumentError)
      end
    end

    context 'with form_data hash and a session object' do
      let(:session_store) { {} }
      let(:form_data) { { 'favourite_meal' => 'pizza', 'ignored_key' => 'nope' } }

      it 'instantiates the form object using the declared attributes' do
        form = FavouriteMealForm.build(form_data, multi_step_form_session: session_store)

        expect(form).to be_a(FavouriteMealForm)
        expect(form.favourite_meal).to eq('pizza')
        expect(form.multi_step_form_session).to be(session_store)
      end
    end
  end

  describe '#save' do
    subject(:form) { form_class.new(favourite_meal: 'pizza', multi_step_form_session: session_store) }

    let(:form_class) do
      Class.new(described_class) do
        attribute :favourite_meal, :string
      end
    end

    let(:session_store) { {} }

    before do
      allow(form).to receive(:valid?).and_return(is_valid)
    end

    context 'for a valid form' do
      let(:is_valid) { true }

      it 'populates session attributes and returns true' do
        expect(form.save).to be(true)
        expect(session_store[:favourite_meal]).to eq('pizza')
      end
    end

    context 'for an invalid form' do
      let(:is_valid) { false }

      it 'does not write to the session and returns false' do
        expect(form.save).to be(false)
        expect(session_store).to be_empty
      end
    end
  end

  describe '#persisted?' do
    it { expect(subject.persisted?).to be(false) }
  end

  describe '#to_key' do
    it { expect(subject.to_key).to be_nil }
  end
end
