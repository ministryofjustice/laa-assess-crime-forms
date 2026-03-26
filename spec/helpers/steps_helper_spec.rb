require 'rails_helper'

RSpec.describe StepsHelper, type: :helper do
  describe '#step_form' do
    let(:record) { double('record') }

    before do
      controller.singleton_class.class_eval { attr_accessor :controller_path }
      controller.controller_path = 'test/path'
      allow(helper).to receive(:form_for)
    end

    context 'when url option is a string path' do
      it 'passes the string url directly to form_for' do
        helper.step_form(record, url: '/custom/path') { nil }

        expect(helper).to have_received(:form_for).with(
          record,
          hash_including(url: '/custom/path', method: :put),
          any_args
        )
      end
    end
  end
end
