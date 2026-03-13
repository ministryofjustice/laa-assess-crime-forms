# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payments::ReturnToCya, type: :controller do
  # Use the real base so multi_step_form_session exists; we override it in before
  controller(Payments::Steps::BaseController) do
    def index
      head :ok
    end
  end

  let(:session_store) { {} }
  let(:multi_step_form_session) { ActiveSupport::HashWithIndifferentAccess.new(session_store) }

  before do
    allow(controller).to receive(:multi_step_form_session).and_return(multi_step_form_session)
  end

  describe '#return_to_cya?' do
    it 'returns true when session return_to is check_your_answers' do
      multi_step_form_session['return_to'] = 'check_your_answers'
      expect(controller.send(:return_to_cya?)).to be true
    end

    it 'returns false when session return_to is blank' do
      multi_step_form_session['return_to'] = nil
      expect(controller.send(:return_to_cya?)).to be false
    end

    it 'returns false when session return_to is something else' do
      multi_step_form_session['return_to'] = 'other'
      expect(controller.send(:return_to_cya?)).to be false
    end
  end

  describe '#clear_return_to_cya!' do
    it 'clears the return_to key in session' do
      multi_step_form_session['return_to'] = 'check_your_answers'
      controller.send(:clear_return_to_cya!)
      expect(multi_step_form_session['return_to']).to be_nil
    end
  end

  describe '#store_return_to_from_params' do
    it 'stores params[:return_to] in session when present' do
      get :index, params: { return_to: 'check_your_answers' }
      controller.send(:store_return_to_from_params)
      expect(multi_step_form_session['return_to']).to eq('check_your_answers')
    end

    it 'does not overwrite session when params[:return_to] is blank' do
      multi_step_form_session['return_to'] = 'check_your_answers'
      get :index, params: {}
      controller.send(:store_return_to_from_params)
      expect(multi_step_form_session['return_to']).to eq('check_your_answers')
    end
  end

  describe '#update_with_return_to_cya' do
    let(:submission_id) { SecureRandom.uuid }
    let(:form_class) { class_double(DummyForm) }
    let(:form_object) { instance_double(DummyForm, save: save_result) }
    let(:params_hash) { ActionController::Parameters.new(foo: 'bar').permit! }
    let(:save_result) { true }

    before do
      stub_const('DummyForm', Class.new)
      allow(controller).to receive(:permitted_params).with(form_class).and_return(params_hash)
      allow(form_class).to receive(:build).and_return(form_object)
      allow(controller).to receive(:redirect_to)
      allow(controller).to receive(:render)
      get :index, params: { id: submission_id }
    end

    it 'returns false when the user is not returning from check your answers' do
      expect(controller.send(:update_with_return_to_cya, form_class, as: :claim_search)).to be(false)
      expect(form_class).not_to have_received(:build)
    end

    it 'saves and redirects back to check your answers when configured' do
      multi_step_form_session['return_to'] = 'check_your_answers'

      expect(
        controller.send(
          :update_with_return_to_cya,
          form_class,
          as: :date_received,
          success_redirect: :check_your_answers
        )
      ).to be(true)

      expect(form_class).to have_received(:build).with({ 'foo' => 'bar' }, multi_step_form_session:)
      expect(controller).to have_received(:redirect_to).with(
        edit_payments_steps_check_your_answers_path(id: submission_id)
      )
      expect(multi_step_form_session['return_to']).to be_nil
    end

    it 'saves and redirects using the decision tree when configured' do
      multi_step_form_session['return_to'] = 'check_your_answers'
      decision_tree = instance_double(Decisions::DecisionTree, destination: '/next-step')

      allow(controller.decision_tree_class).to receive(:new).with(form_object, as: :claim_search).and_return(decision_tree)

      controller.send(:update_with_return_to_cya, form_class, as: :claim_search, success_redirect: :decision_tree)

      expect(controller).to have_received(:redirect_to).with('/next-step')
      expect(multi_step_form_session['return_to']).to eq('check_your_answers')
    end

    it 'saves and redirects using a custom proc when configured' do
      multi_step_form_session['return_to'] = 'check_your_answers'
      redirect_proc = -> { '/custom-destination' }

      controller.send(:update_with_return_to_cya, form_class, as: :office_code_search, success_redirect: redirect_proc)

      expect(controller).to have_received(:redirect_to).with('/custom-destination')
    end

    it 'renders edit and yields when the form does not save' do
      multi_step_form_session['return_to'] = 'check_your_answers'
      allow(form_object).to receive(:save).and_return(false)
      yielded = false

      controller.send(
        :update_with_return_to_cya,
        form_class,
        as: :claim_search,
        render_edit_options: { locals: { page_heading: 'Heading' } }
      ) do
        yielded = true
      end

      expect(yielded).to be(true)
      expect(controller).to have_received(:render).with(:edit, locals: { page_heading: 'Heading' })
    end
  end
end
