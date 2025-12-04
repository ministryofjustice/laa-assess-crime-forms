module Payments
  module Steps
    class ClaimSearchController < BaseController
      def new
        @form_object = Payments::Steps::SelectedClaimForm.build(multi_step_form_session.answers, multi_step_form_session:)
        @search_form = Payments::Steps::ClaimSearchForm.new(search_params)
        @search_form.execute if @search_form.valid?

        render :edit
      end

      def edit
        @form_object = Payments::Steps::SelectedClaimForm.build(multi_step_form_session.answers, multi_step_form_session:)
        @search_form = Payments::Steps::ClaimSearchForm.new(default_params)
      end

      def update
        update_and_advance(Payments::Steps::SelectedClaimForm, as: :claim_search)
      end

      private

      def search_params
        params.expect(
          payments_steps_claim_search_form: [:query,
                                             :sort_by,
                                             :sort_direction]
        ).merge(default_params)
      end

      def default_params
        {
          page: params.fetch(:page, '1'),
          search_scope: search_scope
        }
      end

      def search_scope
        search_scope = multi_step_form_session['request_type']
                       .sub(/_(supplemental|appeal|amendment)\z/, '').sub(/mag\z/, 'magistrate')

        # :nocov:
        case search_scope.to_sym
        when :non_standard_magistrate, :breach_of_injunction
          :nsm_claim
        when :assigned_counsel_claim
          :ac_claim
        end
        # :nocov:
      end
    end
  end
end
