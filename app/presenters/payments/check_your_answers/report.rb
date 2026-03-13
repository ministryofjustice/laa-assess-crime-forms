module Payments
  module CheckYourAnswers
    class Report
      include GovukLinkHelper
      include GovukVisuallyHiddenHelper
      include ActionView::Helpers::UrlHelper

      attr_reader :session_answers

      def show_groups
        default_groups = %w[
          claim_types
          linked_claim
          claim_details
        ]

        default_groups.reject! { _1 == 'linked_claim' } unless linked_claim?
        default_groups
      end

      def initialize(session_answers)
        @session_answers = session_answers
      end

      def section_groups
        show_groups.compact.map do |group_name|
          section_group(public_send(:"#{group_name}_section"))
        end
      end

      def section_group(section_list)
        {
          sections: sections(section_list)
        }
      end

      def sections(section_list)
        section_list.map do |card|
          {
            card: {
              title: card.title,
              actions: actions(card)
            },
            rows: card.rows,
            custom: card.custom
          }
        end
      end

      def claim_types_section
        [ClaimTypesCard.new(session_answers)]
      end

      def claim_details_section
        case session_answers['request_type'].to_sym
        when :breach_of_injunction, :non_standard_magistrate, :non_standard_mag_supplemental,
             :non_standard_mag_amendment, :non_standard_mag_appeal
          [ClaimDetailsCard.new(session_answers)]
        when :assigned_counsel, :assigned_counsel_appeal, :assigned_counsel_amendment
          [AcClaimDetailsCard.new(session_answers)]
        # :nocov:
        else
          false
        end
        # :nocov:
      end

      def linked_claim_section
        [LinkedClaimCard.new(session_answers)]
      end

      private

      def linked_claim?
        [:non_standard_mag_supplemental,
         :non_standard_mag_amendment,
         :non_standard_mag_appeal,
         :assigned_counsel_appeal,
         :assigned_counsel_amendment].include?(session_answers['request_type'].to_sym)
      end

      def actions(card)
        return [] if card.read_only?

        helper = Rails.application.routes.url_helpers
        [
          govuk_link_to(
            I18n.t('payments.steps.check_your_answers.edit.change'),
            helper.url_for(
              controller: card.change_link_controller_path,
              action: card.change_link_controller_method,
              id: session_answers['id'],
              **card.change_link_query_params,
              only_path: true
            )
          ),
        ]
      end
    end
  end
end
