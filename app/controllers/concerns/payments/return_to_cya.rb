# frozen_string_literal: true

module Payments
  # Shared logic for payment step controllers that support "return to Check your answers"
  # when the user clicks "Change" on the CYA page. Stores return_to in session and handles
  # save + redirect (to CYA or next step) without advancing the normal flow.
  module ReturnToCya
    extend ActiveSupport::Concern

    private

    def return_to_cya?
      multi_step_form_session['return_to'] == 'check_your_answers'
    end

    def clear_return_to_cya!
      multi_step_form_session['return_to'] = nil
    end

    def store_return_to_from_params
      multi_step_form_session['return_to'] = params[:return_to] if params[:return_to].present?
    end

    # When the user came from CYA (return_to_cya?), build form from params, save, and redirect
    # on success; otherwise render :edit. Returns true if the request was handled (caller should
    # return), false if the caller should continue with update_and_advance.
    #
    # @param form_class [Class] the form object class (e.g. Payments::Steps::SelectedClaimForm)
    # @param as [Symbol] step name for decision tree (e.g. :claim_search)
    # @param success_redirect [Symbol, Proc] :check_your_answers (redirect to CYA and clear),
    #   :decision_tree (redirect to decision tree destination), or a Proc that returns a path
    # @param render_edit_options [Hash] optional options merged into render :edit (e.g. locals: { page_heading: })
    # @yield optional block run before rendering :edit on validation failure (e.g. set @search_form)
    # rubocop:disable Naming/PredicateMethod -- returns handled? not a predicate
    def update_with_return_to_cya(
      form_class, as:, success_redirect: :check_your_answers,
      render_edit_options: {}, &_block
    )
      return false unless return_to_cya?

      hash = permitted_params(form_class).to_h
      @form_object = form_class.build(hash, multi_step_form_session:)

      if @form_object.save
        path = success_redirect_path(success_redirect, as)
        clear_return_to_cya! if success_redirect == :check_your_answers
        redirect_to path
      else
        yield if block_given?
        render :edit, **render_edit_options
      end
      true
    end
    # rubocop:enable Naming/PredicateMethod

    def success_redirect_path(success_redirect, as)
      case success_redirect
      when :check_your_answers
        edit_payments_steps_check_your_answers_path(id: params[:id])
      when :decision_tree
        decision_tree_class.new(@form_object, as:).destination
      when Proc
        success_redirect.call
      else
        raise ArgumentError, "Unknown success_redirect: #{success_redirect.inspect}"
      end
    end
  end
end
