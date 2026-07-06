module Payments
  module CheckYourAnswers
    class Report
      include GovukLinkHelper
      include GovukVisuallyHiddenHelper
      include ActionView::Helpers::UrlHelper

      attr_reader :session_answers, :params

      def show_groups
        %w[
          claim_types
          claim_details
        ]
      end

      def initialize(session_answers, params)
        @session_answers = session_answers
        @params = params
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
          [NsmClaimDetailsCard.new(session_answers, params)]
        when :assigned_counsel, :assigned_counsel_appeal, :assigned_counsel_amendment
          [AcClaimDetailsCard.new(session_answers, params)]
        # :nocov:
        else
          false
        end
        # :nocov:
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
      def cost_summary
        case session_answers['request_type'].to_sym
        when :non_standard_magistrate, :breach_of_injunction
          Payments::NsmCostsSummary.new(session_answers)
        when :non_standard_mag_supplemental
          if session_answers['laa_reference'].present? || session_answers['linked_laa_reference'].present?
            Payments::NsmCostsSummaryAmendedAndClaimed.new(session_answers)
          else
            Payments::NsmCostsSummary.new(session_answers)
          end
        when :non_standard_mag_amendment, :non_standard_mag_appeal
          Payments::NsmCostsSummaryAmended.new(session_answers)
        when :assigned_counsel
          Payments::AcCostsSummary.new(session_answers)
        when :assigned_counsel_appeal
          Payments::AcCostsSummaryAppealed.new(session_answers)
        when :assigned_counsel_amendment
          Payments::AcCostsSummaryAmended.new(session_answers)
          # :nocov:
        else
          raise StandardError, "Unknown request type: #{session_answers['request_type']}"
        end
        # :nocov:
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity

      private

      def actions(card)
        return [] if card.read_only?

        helper = Rails.application.routes.url_helpers
        [
          govuk_link_to(
            I18n.t('payments.steps.check_your_answers.edit.change'),
            helper.url_for(controller: card.change_link_controller_path, action: card.change_link_controller_method,
                           id: card.change_link_session_id, only_path: true)
          ),
        ]
      end
    end
  end
end
