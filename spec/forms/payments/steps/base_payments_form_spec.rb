require 'rails_helper'

RSpec.describe Payments::Steps::BasePaymentsForm do
  describe '.build' do
    let(:video_game_form) do
      Class.new(described_class) do
        attribute :video_game, :string
      end
    end

    before do
      stub_const('VideoGameForm', video_game_form)
    end

    context 'when missing the required multi_step_form_session keyword' do
      it 'raises an ArgumentError' do
        expect do
          VideoGameForm.build({})
        end.to raise_error(ArgumentError)
      end
    end

    context 'with form_data hash and a session object' do
      let(:session_store) { {} }
      let(:form_data) { { 'video_game' => 'worms', 'ignored_key' => 'nope' } }

      it 'instantiates the form object using the declared attributes' do
        form = VideoGameForm.build(form_data, multi_step_form_session: session_store)

        expect(form).to be_a(VideoGameForm)
        expect(form.video_game).to eq('worms')
        expect(form.multi_step_form_session).to be(session_store)
      end
    end
  end

  describe '#save' do
    subject(:form) { form_class.new(video_game: 'zelda', multi_step_form_session: session_store) }

    let(:form_class) do
      Class.new(described_class) do
        attribute :video_game, :string
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
        expect(session_store[:video_game]).to eq('zelda')
      end

      context 'when the session already contains an answer' do
        before do
          session_store[:video_game] = 'mario'
        end

        it 'overwrites the existing value with the new one' do
          expect { form.save }.to change { session_store[:video_game] }
            .from('mario').to('zelda')
        end
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
