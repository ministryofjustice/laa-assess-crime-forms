require 'rails_helper'

RSpec.describe Payments::MultiStepFormSessionConcern, type: :controller do
  controller(ApplicationController) do
    # rubocop:disable RSpec/DescribedClass
    include Payments::MultiStepFormSessionConcern
    # rubocop:enable RSpec/DescribedClass

    def index
      head :ok
    end
  end

  let(:session_store) { ActiveSupport::HashWithIndifferentAccess.new }

  before do
    allow(controller).to receive(:session).and_return(session_store)
  end

  describe '#destroy_current_form_session' do
    before do
      session_store['multi_step_form_id'] = 'abc-123'
      session_store['payments:abc-123'] = { some: 'data' }
      controller.destroy_current_form_sessions
    end

    it 'removes both the multi_step_form_id and the namespaced session key' do
      expect(session_store).not_to have_key('multi_step_form_id')
      expect(session_store).not_to have_key('payments:abc-123')
    end
  end

  describe '#current_multi_step_form_session' do
    let(:uuid) { 'session-456' }
    let(:mock_session_object) { instance_double(Decisions::MultiStepFormSession) }

    before do
      session_store[:multi_step_form_id] = uuid
      allow(Decisions::MultiStepFormSession)
        .to receive(:new)
        .with(process: 'payments', session: session_store, session_id: uuid)
        .and_return(mock_session_object)
    end

    it 'instantiates a MultiStepFormSession with correct arguments' do
      controller.current_multi_step_form_session
      expect(Decisions::MultiStepFormSession)
        .to have_received(:new)
        .with(process: 'payments', session: session_store, session_id: uuid)
    end
  end
end
